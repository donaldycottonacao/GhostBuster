#!/usr/bin/env python3
"""GhostBuster - Audio validation utilities (standard library only).

Checks that an audio file is structurally valid and plausible for use as a
simulated-call voice asset. Objective checks only: a file that passes here can
still sound bad. A human listening check is a separate, mandatory step.

Analysis levels
---------------
* ``.wav`` (PCM 8/16/24/32-bit): full analysis (duration, peak, RMS, clipping,
  silence, leading/trailing silence).
* ``.mp3``: header-only check (ID3 tag or MPEG frame sync). Duration, clipping
  and silence are NOT verified because no MP3 decoder is bundled.
* Other extensions: rejected as unsupported by this validator.

Exit codes (CLI): 0 = valid, 1 = invalid / unreadable / unsupported.
"""

from __future__ import annotations

import argparse
import json
import math
import sys
import wave
from array import array
from dataclasses import asdict, dataclass, field
from pathlib import Path

SUPPORTED_EXTENSIONS = (".wav", ".mp3")

MIN_DURATION_SECONDS = 0.3
MAX_DURATION_SECONDS = 120.0
MAX_FILE_BYTES = 5 * 1024 * 1024
MIN_PEAK_AMPLITUDE = 0.01  # below this the file is treated as silent (-40 dBFS)
MIN_ACTIVE_RATIO = 0.05  # fraction of 20 ms windows that must contain signal
SILENCE_RMS_THRESHOLD = 10 ** (-45 / 20)  # -45 dBFS per 20 ms window
CLIP_LEVEL = 0.999
CLIPPED_RATIO_WARNING = 0.001
LONG_LEADING_SILENCE_SECONDS = 1.0
LONG_TRAILING_SILENCE_SECONDS = 1.5
LOW_SAMPLE_RATE_HZ = 16000
WINDOW_SECONDS = 0.02


@dataclass
class AudioReport:
    """Result of validating one audio file."""

    path: str
    format: str = "unknown"
    analysis_level: str = "none"  # "full", "header-only" or "none"
    ok: bool = False
    size_bytes: int = 0
    sample_rate: int | None = None
    channels: int | None = None
    sample_width_bits: int | None = None
    duration_seconds: float | None = None
    peak: float | None = None
    rms: float | None = None
    clipped_ratio: float | None = None
    active_ratio: float | None = None
    leading_silence_seconds: float | None = None
    trailing_silence_seconds: float | None = None
    errors: list[str] = field(default_factory=list)
    warnings: list[str] = field(default_factory=list)

    def to_dict(self) -> dict:
        return asdict(self)


def _decode_frames(raw: bytes, sample_width: int, channels: int) -> list[float]:
    """Return one normalized peak magnitude (0..1) per audio frame."""
    if sample_width == 1:  # unsigned 8-bit
        samples = [abs(b - 128) / 128.0 for b in raw]
    elif sample_width == 2:
        buf = array("h")
        buf.frombytes(raw[: len(raw) - len(raw) % 2])
        if sys.byteorder == "big":
            buf.byteswap()
        samples = [abs(v) / 32768.0 for v in buf]
    elif sample_width == 3:
        samples = []
        usable = len(raw) - len(raw) % 3
        for i in range(0, usable, 3):
            value = int.from_bytes(raw[i : i + 3], "little", signed=True)
            samples.append(abs(value) / 8388608.0)
    elif sample_width == 4:
        buf = array("i")
        buf.frombytes(raw[: len(raw) - len(raw) % 4])
        if sys.byteorder == "big":
            buf.byteswap()
        samples = [abs(v) / 2147483648.0 for v in buf]
    else:
        raise ValueError(f"unsupported sample width: {sample_width} bytes")

    if channels == 1:
        return samples
    frames = []
    usable = len(samples) - len(samples) % channels
    for i in range(0, usable, channels):
        frames.append(max(samples[i : i + channels]))
    return frames


def _validate_wav(path: Path, report: AudioReport) -> None:
    report.format = "wav"
    try:
        with wave.open(str(path), "rb") as wav:
            channels = wav.getnchannels()
            sample_width = wav.getsampwidth()
            rate = wav.getframerate()
            n_frames = wav.getnframes()
            comptype = wav.getcomptype()
            raw = wav.readframes(n_frames)
    except (wave.Error, EOFError) as exc:
        report.errors.append(f"Unreadable or unsupported WAV file: {exc}")
        return

    report.analysis_level = "full"
    report.sample_rate = rate
    report.channels = channels
    report.sample_width_bits = sample_width * 8

    if comptype != "NONE":
        report.errors.append(f"Compressed WAV is not supported (type {comptype}).")
        return
    if rate <= 0 or channels <= 0 or n_frames <= 0:
        report.errors.append("WAV contains no audio frames.")
        report.duration_seconds = 0.0
        return

    report.duration_seconds = round(n_frames / rate, 3)
    try:
        frames = _decode_frames(raw, sample_width, channels)
    except ValueError as exc:
        report.errors.append(str(exc))
        return
    if not frames:
        report.errors.append("WAV contains no decodable samples.")
        return

    peak = max(frames)
    rms = math.sqrt(sum(v * v for v in frames) / len(frames))
    clipped = sum(1 for v in frames if v >= CLIP_LEVEL) / len(frames)
    report.peak = round(peak, 4)
    report.rms = round(rms, 4)
    report.clipped_ratio = round(clipped, 6)

    window = max(1, int(rate * WINDOW_SECONDS))
    active_flags = []
    for start in range(0, len(frames), window):
        chunk = frames[start : start + window]
        chunk_rms = math.sqrt(sum(v * v for v in chunk) / len(chunk))
        active_flags.append(chunk_rms >= SILENCE_RMS_THRESHOLD)
    report.active_ratio = round(sum(active_flags) / len(active_flags), 4)

    leading = 0
    for flag in active_flags:
        if flag:
            break
        leading += 1
    trailing = 0
    for flag in reversed(active_flags):
        if flag:
            break
        trailing += 1
    report.leading_silence_seconds = round(leading * WINDOW_SECONDS, 3)
    report.trailing_silence_seconds = round(trailing * WINDOW_SECONDS, 3)

    if report.duration_seconds < MIN_DURATION_SECONDS:
        report.errors.append(
            f"Duration {report.duration_seconds}s is shorter than {MIN_DURATION_SECONDS}s."
        )
    if report.duration_seconds > MAX_DURATION_SECONDS:
        report.errors.append(
            f"Duration {report.duration_seconds}s exceeds {MAX_DURATION_SECONDS}s."
        )
    if peak < MIN_PEAK_AMPLITUDE or report.active_ratio < MIN_ACTIVE_RATIO:
        report.errors.append("Audio is silent or near-silent (no audible signal).")
    if clipped > CLIPPED_RATIO_WARNING:
        report.warnings.append(
            f"Possible clipping: {clipped:.4%} of samples at full scale."
        )
    elif peak >= CLIP_LEVEL:
        report.warnings.append("Peak reaches full scale; check for distortion.")
    if report.leading_silence_seconds > LONG_LEADING_SILENCE_SECONDS:
        report.warnings.append(
            f"Long leading silence ({report.leading_silence_seconds}s)."
        )
    if report.trailing_silence_seconds > LONG_TRAILING_SILENCE_SECONDS:
        report.warnings.append(
            f"Long trailing silence ({report.trailing_silence_seconds}s)."
        )
    if rate < LOW_SAMPLE_RATE_HZ:
        report.warnings.append(f"Low sample rate ({rate} Hz); speech may sound dull.")


def _validate_mp3(path: Path, report: AudioReport) -> None:
    report.format = "mp3"
    report.analysis_level = "header-only"
    try:
        with path.open("rb") as handle:
            head = handle.read(4096)
    except OSError as exc:
        report.errors.append(f"Cannot read file: {exc}")
        return

    has_id3 = head.startswith(b"ID3")
    has_sync = any(
        head[i] == 0xFF and (head[i + 1] & 0xE0) == 0xE0 for i in range(len(head) - 1)
    )
    if not (has_id3 or has_sync):
        report.errors.append("File does not look like MP3 (no ID3 tag or frame sync).")
        return
    report.warnings.append(
        "MP3 checked by header only: duration, clipping and silence NOT verified."
    )


def validate_audio(path: str | Path) -> AudioReport:
    """Validate ``path`` and return a structured report. Never raises for bad input."""
    file_path = Path(path)
    report = AudioReport(path=str(file_path))

    if not file_path.exists():
        report.errors.append(f"File not found: {file_path}")
        return report
    if not file_path.is_file():
        report.errors.append(f"Not a regular file: {file_path}")
        return report

    suffix = file_path.suffix.lower()
    if suffix not in SUPPORTED_EXTENSIONS:
        report.errors.append(
            f"Unsupported extension '{suffix}'. Supported: {', '.join(SUPPORTED_EXTENSIONS)}."
        )
        return report

    report.size_bytes = file_path.stat().st_size
    if report.size_bytes == 0:
        report.errors.append("File is empty (0 bytes).")
        return report
    if report.size_bytes > MAX_FILE_BYTES:
        report.warnings.append(
            f"Large file ({report.size_bytes / 1024 / 1024:.1f} MiB) for a bundled asset."
        )

    if suffix == ".wav":
        _validate_wav(file_path, report)
    else:
        _validate_mp3(file_path, report)

    report.ok = not report.errors
    return report


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Validate an audio file for use as a GhostBuster voice asset."
    )
    parser.add_argument("audio_file", help="Path to a .wav or .mp3 file.")
    parser.add_argument("--json", action="store_true", help="Print the report as JSON.")
    args = parser.parse_args(argv)

    report = validate_audio(args.audio_file)
    if args.json:
        print(json.dumps(report.to_dict(), indent=2))
    else:
        status = "VALID" if report.ok else "INVALID"
        print(f"[{status}] {report.path}")
        print(f"  format={report.format} analysis={report.analysis_level}")
        if report.duration_seconds is not None:
            print(
                f"  duration={report.duration_seconds}s rate={report.sample_rate}Hz "
                f"channels={report.channels} bits={report.sample_width_bits}"
            )
            print(
                f"  peak={report.peak} rms={report.rms} clipped={report.clipped_ratio} "
                f"active={report.active_ratio}"
            )
            print(
                f"  lead_silence={report.leading_silence_seconds}s "
                f"trail_silence={report.trailing_silence_seconds}s"
            )
        for warning in report.warnings:
            print(f"  WARNING: {warning}")
        for error in report.errors:
            print(f"  ERROR: {error}", file=sys.stderr)
        print("  NOTE: objective checks only; a human listening check is still required.")
    return 0 if report.ok else 1


if __name__ == "__main__":
    sys.exit(main())
