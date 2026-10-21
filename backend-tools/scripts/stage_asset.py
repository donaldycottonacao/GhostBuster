#!/usr/bin/env python3
"""GhostBuster - Approved asset staging tool.

Copies ONE reviewed audio file from a private location into
``frontend-client/assets/audio/``. This is the only sanctioned path from
generated audio to the Flutter app, and it requires explicit human attestations:

* ``--approved-by``      who approved the asset for distribution
* ``--license-note``     licensing / consent basis (free text, recorded in output)
* ``--confirm-listened`` the approver has actually listened to the file

Refusals: raw voice samples, invalid audio, extension/format mismatch, target
names the Flutter code does not reference, and overwriting without --overwrite.

The tool never edits ``pubspec.yaml`` (``assets/audio/`` is already registered as
a directory) and never runs git.

Exit codes: 0 staged / dry-run ok, 1 refused.
"""

from __future__ import annotations

import argparse
import re
import shutil
import sys
from pathlib import Path

SCRIPTS_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPTS_DIR))

from audio_validation import validate_audio  # noqa: E402

BACKEND_DIR = SCRIPTS_DIR.parent
REPO_ROOT = BACKEND_DIR.parent
DEFAULT_ASSETS_DIR = REPO_ROOT / "frontend-client" / "assets" / "audio"
DEFAULT_LIB_DIR = REPO_ROOT / "frontend-client" / "lib"
VOICE_SAMPLES_DIR = (BACKEND_DIR / "voice_samples").resolve()
TARGET_NAME_PATTERN = re.compile(r"^[a-z0-9_]+\.(wav|mp3)$")


def parse_arguments(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Stage one reviewed, approved audio file for the Flutter app."
    )
    parser.add_argument("--source", required=True, help="Reviewed audio file (.wav/.mp3).")
    parser.add_argument(
        "--target-name",
        required=True,
        help="Destination filename, e.g. peer_mom.mp3 (lowercase, digits, underscore).",
    )
    parser.add_argument("--approved-by", required=True, help="Name of the approver.")
    parser.add_argument(
        "--license-note",
        required=True,
        help="Licensing/consent basis for distribution (recorded, not verified).",
    )
    parser.add_argument(
        "--confirm-listened",
        action="store_true",
        help="Certify that a human listened to the file and found it intelligible.",
    )
    parser.add_argument("--overwrite", action="store_true", help="Replace an existing asset.")
    parser.add_argument(
        "--allow-unreferenced",
        action="store_true",
        help="Allow a target name that no Dart source under frontend-client/lib references.",
    )
    parser.add_argument("--dry-run", action="store_true", help="Check everything, copy nothing.")
    parser.add_argument("--assets-dir", default=str(DEFAULT_ASSETS_DIR), help=argparse.SUPPRESS)
    parser.add_argument("--lib-dir", default=str(DEFAULT_LIB_DIR), help=argparse.SUPPRESS)
    return parser.parse_args(argv)


def is_referenced(lib_dir: Path, target_name: str) -> bool:
    needle = f"assets/audio/{target_name}"
    if not lib_dir.is_dir():
        return False
    for dart_file in lib_dir.rglob("*.dart"):
        try:
            if needle in dart_file.read_text(encoding="utf-8", errors="ignore"):
                return True
        except OSError:
            continue
    return False


def check(args: argparse.Namespace) -> str | None:
    """Return a refusal message, or ``None`` when staging is allowed."""
    if not args.confirm_listened:
        return "Refused: --confirm-listened is required (a human must listen first)."
    if not args.approved_by.strip() or not args.license_note.strip():
        return "Refused: --approved-by and --license-note must not be empty."
    if not TARGET_NAME_PATTERN.match(args.target_name):
        return (
            "Refused: --target-name must match [a-z0-9_]+.(wav|mp3) and must not "
            "contain personal details."
        )

    source = Path(args.source).resolve()
    try:
        source.relative_to(VOICE_SAMPLES_DIR)
    except ValueError:
        pass
    else:
        return "Refused: raw voice samples can never be staged as application assets."

    report = validate_audio(source)
    if not report.ok:
        return "Refused: source audio failed validation: " + "; ".join(report.errors)
    if Path(args.target_name).suffix.lower() != source.suffix.lower():
        return (
            f"Refused: source is {source.suffix.lower()} but target is "
            f"{Path(args.target_name).suffix.lower()}. Convert properly; do not just rename."
        )
    if not args.allow_unreferenced and not is_referenced(Path(args.lib_dir), args.target_name):
        return (
            f"Refused: no Dart source references 'assets/audio/{args.target_name}'. "
            "Use the exact name from the scenario mapping, or --allow-unreferenced."
        )
    destination = Path(args.assets_dir) / args.target_name
    if destination.exists() and not args.overwrite:
        return f"Refused: {destination.name} already exists. Review the diff, then use --overwrite."
    return None


def main(argv: list[str] | None = None) -> int:
    args = parse_arguments(argv)
    problem = check(args)
    if problem:
        sys.stderr.write(f"\n[STAGING REFUSED] {problem}\n\n")
        return 1

    destination = Path(args.assets_dir) / args.target_name
    print(f"[*] Source       : {Path(args.source).resolve()}")
    print(f"[*] Destination  : {destination.resolve()}")
    print(f"[*] Approved by  : {args.approved_by}")
    print(f"[*] License note : {args.license_note}")
    if args.dry_run:
        print("[INFO] Dry run complete. Nothing copied.")
        return 0

    Path(args.assets_dir).mkdir(parents=True, exist_ok=True)
    shutil.copyfile(args.source, destination)
    print(f"[SUCCESS] Staged {destination.name}.")
    print("[NEXT] 1) Record this approval in docs/phase-8-voice-asset-tools.md.")
    print("       2) assets/audio/ is already registered in pubspec.yaml (directory entry).")
    print("       3) .gitignore ignores assets/audio/*.mp3|wav by default: add an explicit")
    print(f"          '!frontend-client/assets/audio/{destination.name}' rule only if approved to commit.")
    print("       4) Run flutter analyze / test / build and verify playback offline.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
