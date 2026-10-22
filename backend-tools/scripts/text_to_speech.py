#!/usr/bin/env python3
"""GhostBuster - Local Text-to-Speech Tool (Windows SAPI).

Synthesizes a short dialogue clip using a voice that is **already installed in
Windows** (System.Speech / SAPI5, driven through Windows PowerShell). Generation
is fully local and offline: no network, no API key, no model download, and no
third-party Python package.

What it does NOT do
-------------------
* It does not clone anyone's voice (see ``clone_peer.py``).
* It writes WAV only. MP3 output needs an external converter (e.g. ffmpeg) that
  is not bundled; requesting ``.mp3`` fails with an explanatory error.

LEGAL & ETHICAL NOTICE
----------------------
Voice synthesis must adhere to voice licensing or explicit speaker consent.
Impersonation, defamation and deceptive use are prohibited. Installed Windows
voices are licensed by Microsoft; whether their *output* may be redistributed
inside a published app has NOT been verified by this project - treat generated
files as private development assets until a human approves them.

Exit codes
----------
0 success / dry-run ok, 1 invalid input or policy violation,
4 generated audio failed validation, 5 speech engine unavailable or failed.
"""

from __future__ import annotations

import argparse
import os
import subprocess
import sys
from pathlib import Path

SCRIPTS_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPTS_DIR))

from audio_validation import validate_audio  # noqa: E402

BACKEND_DIR = SCRIPTS_DIR.parent
REPO_ROOT = BACKEND_DIR.parent
DEFAULT_OUTPUT = BACKEND_DIR / "output_assets" / "simulated_dialogue.wav"
FLUTTER_ASSETS_DIR = (REPO_ROOT / "frontend-client" / "assets").resolve()
MAX_TEXT_CHARS = 1000

EXIT_OK = 0
EXIT_INVALID = 1
EXIT_OUTPUT_INVALID = 4
EXIT_ENGINE = 5

_SYNTH_SCRIPT = (
    "Add-Type -AssemblyName System.Speech; "
    "$s = New-Object System.Speech.Synthesis.SpeechSynthesizer; "
    "try { "
    "if ($env:GB_TTS_VOICE) { $s.SelectVoice($env:GB_TTS_VOICE) }; "
    "$s.Rate = [int]$env:GB_TTS_RATE; "
    "$s.SetOutputToWaveFile($env:GB_TTS_OUT); "
    "$s.Speak($env:GB_TTS_TEXT) "
    "} finally { $s.Dispose() }"
)
_LIST_SCRIPT = (
    "Add-Type -AssemblyName System.Speech; "
    "$s = New-Object System.Speech.Synthesis.SpeechSynthesizer; "
    "$s.GetInstalledVoices() | ForEach-Object { "
    "$_.VoiceInfo.Name + '|' + $_.VoiceInfo.Culture.Name }; "
    "$s.Dispose()"
)


class EngineError(RuntimeError):
    """Raised when the local speech engine is unavailable or fails."""


def parse_arguments(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="GhostBuster - local text-to-speech (Windows SAPI voices, WAV output).",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python scripts/text_to_speech.py --list-voices
  python scripts/text_to_speech.py --text "Hey, can you call me back?" \\
      --voice-model "Zira" --output-file output_assets/test_sample.wav \\
      --authorized-voice --dry-run
  python scripts/text_to_speech.py --text "Hey, can you call me back?" \\
      --output-file output_assets/test_sample.wav --authorized-voice
""",
    )
    parser.add_argument("--text", type=str, help="Dialogue text to synthesize.")
    parser.add_argument(
        "--voice-model",
        type=str,
        default="",
        help="Installed Windows voice name (case-insensitive substring, e.g. 'Zira'). "
        "Default: the system default voice. See --list-voices.",
    )
    parser.add_argument(
        "--output-file",
        type=str,
        default=str(DEFAULT_OUTPUT),
        help="Output .wav path (default: backend-tools/output_assets/simulated_dialogue.wav).",
    )
    parser.add_argument(
        "--rate",
        type=int,
        default=0,
        help="Speaking rate from -10 (slow) to 10 (fast). Default 0.",
    )
    parser.add_argument(
        "--authorized-voice",
        action="store_true",
        help="Certify the chosen voice is licensed or authorized by the speaker.",
    )
    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="Allow replacing an existing output file (default: refuse).",
    )
    parser.add_argument(
        "--list-voices",
        action="store_true",
        help="List installed Windows voices and exit.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Validate arguments and the voice choice without writing any audio.",
    )
    return parser.parse_args(argv)


def list_installed_voices() -> list[tuple[str, str]]:
    """Return ``(name, culture)`` for each installed SAPI voice."""
    if os.name != "nt":
        raise EngineError("This tool uses Windows SAPI and only runs on Windows.")
    try:
        result = subprocess.run(
            ["powershell.exe", "-NoProfile", "-NonInteractive", "-Command", _LIST_SCRIPT],
            capture_output=True,
            text=True,
            timeout=60,
        )
    except (OSError, subprocess.TimeoutExpired) as exc:
        raise EngineError(f"Could not run Windows PowerShell: {exc}") from exc
    if result.returncode != 0:
        raise EngineError(f"Could not list voices: {result.stderr.strip()[:300]}")
    voices = []
    for line in result.stdout.splitlines():
        if "|" in line:
            name, culture = line.strip().split("|", 1)
            voices.append((name, culture))
    return voices


def resolve_voice(requested: str, installed: list[tuple[str, str]]) -> str:
    """Map a user-supplied voice string to one installed voice name ('' = default)."""
    if not requested.strip():
        return ""
    needle = requested.strip().lower()
    exact = [name for name, _ in installed if name.lower() == needle]
    if exact:
        return exact[0]
    partial = [name for name, _ in installed if needle in name.lower()]
    if len(partial) == 1:
        return partial[0]
    if not partial:
        raise ValueError(
            f"Voice '{requested}' is not installed. Installed: "
            f"{', '.join(n for n, _ in installed) or 'none'}."
        )
    raise ValueError(
        f"Voice '{requested}' is ambiguous. Matches: {', '.join(partial)}."
    )


def validate_parameters(args: argparse.Namespace) -> str | None:
    """Return an error message, or ``None`` when all arguments are acceptable."""
    if not args.authorized_voice:
        return (
            "[ETHICS & LICENSING ERROR] Voice authorization flag missing. Pass "
            "'--authorized-voice' to certify the chosen voice is licensed for synthesis "
            "or backed by explicit consent."
        )
    if args.text is None or not args.text.strip():
        return "[VALIDATION ERROR] --text is required and cannot be empty."
    if len(args.text) > MAX_TEXT_CHARS:
        return f"[VALIDATION ERROR] Text exceeds {MAX_TEXT_CHARS} characters."
    if not -10 <= args.rate <= 10:
        return "[VALIDATION ERROR] --rate must be between -10 and 10."

    output_path = Path(args.output_file)
    suffix = output_path.suffix.lower()
    if suffix == ".mp3":
        return (
            "[UNSUPPORTED FORMAT] This tool writes WAV only. Generate a .wav, then "
            "convert externally (e.g. ffmpeg) if an .mp3 asset is required."
        )
    if suffix != ".wav":
        return f"[INVALID EXTENSION] Output '{output_path.name}' must end in .wav."

    resolved = output_path.resolve()
    try:
        resolved.relative_to(FLUTTER_ASSETS_DIR)
    except ValueError:
        pass
    else:
        return (
            "[POLICY ERROR] Refusing to write directly into frontend-client/assets. "
            "Generate into backend-tools/output_assets/, review, then use stage_asset.py."
        )
    if output_path.exists() and not args.overwrite:
        return (
            f"[OUTPUT EXISTS] '{output_path}' already exists. Use --overwrite to replace it."
        )
    return None


def synthesize(text: str, voice: str, rate: int, destination: Path) -> None:
    """Run SAPI synthesis into ``destination``. Raises ``EngineError`` on failure."""
    env = dict(os.environ)
    env.update(
        GB_TTS_TEXT=text,
        GB_TTS_VOICE=voice,
        GB_TTS_RATE=str(rate),
        GB_TTS_OUT=str(destination),
    )
    try:
        result = subprocess.run(
            ["powershell.exe", "-NoProfile", "-NonInteractive", "-Command", _SYNTH_SCRIPT],
            capture_output=True,
            text=True,
            timeout=300,
            env=env,
        )
    except (OSError, subprocess.TimeoutExpired) as exc:
        raise EngineError(f"Speech synthesis could not run: {exc}") from exc
    if result.returncode != 0:
        raise EngineError(f"Speech synthesis failed: {result.stderr.strip()[:300]}")


def run(args: argparse.Namespace) -> int:
    if args.list_voices:
        try:
            for name, culture in list_installed_voices():
                print(f"{name} ({culture})")
        except EngineError as exc:
            sys.stderr.write(f"[ENGINE ERROR] {exc}\n")
            return EXIT_ENGINE
        return EXIT_OK

    problem = validate_parameters(args)
    if problem:
        sys.stderr.write(f"\n{problem}\n\n")
        return EXIT_INVALID

    try:
        installed = list_installed_voices() if args.voice_model.strip() else []
        voice = resolve_voice(args.voice_model, installed)
    except EngineError as exc:
        sys.stderr.write(f"[ENGINE ERROR] {exc}\n")
        return EXIT_ENGINE
    except ValueError as exc:
        sys.stderr.write(f"[VOICE ERROR] {exc}\n")
        return EXIT_INVALID

    output_path = Path(args.output_file).resolve()
    print("GhostBuster - local text-to-speech (Windows SAPI, offline)")
    print(f"[*] Voice        : {voice or '(system default)'}")
    print(f"[*] Text length  : {len(args.text)} characters")
    print(f"[*] Output file  : {output_path}")

    if args.dry_run:
        print("[INFO] Dry run complete. No audio generated, no files written.")
        return EXIT_OK

    output_path.parent.mkdir(parents=True, exist_ok=True)
    partial = output_path.with_name(output_path.stem + ".partial.wav")
    try:
        synthesize(args.text, voice, args.rate, partial)
    except EngineError as exc:
        partial.unlink(missing_ok=True)
        sys.stderr.write(f"[ENGINE ERROR] {exc}\n")
        return EXIT_ENGINE

    report = validate_audio(partial)
    if not report.ok:
        partial.unlink(missing_ok=True)
        sys.stderr.write("[OUTPUT INVALID] Generated audio failed validation:\n")
        for error in report.errors:
            sys.stderr.write(f"  - {error}\n")
        return EXIT_OUTPUT_INVALID

    os.replace(partial, output_path)
    print(
        f"[SUCCESS] Wrote {output_path.name}: {report.duration_seconds}s, "
        f"{report.sample_rate} Hz, {report.channels} ch"
    )
    for warning in report.warnings:
        print(f"[WARNING] {warning}")
    print("[NEXT] Listen to the file, then review/approve before staging for Flutter.")
    return EXIT_OK


def main() -> None:
    sys.exit(run(parse_arguments()))


if __name__ == "__main__":
    main()
