#!/usr/bin/env python3
"""Tests for audio validation, TTS tool validation/failure handling, and staging.

No network, no model downloads, no private recordings. Speech synthesis is mocked;
one optional integration test (real Windows SAPI) is skipped unless the environment
variable GHOSTBUSTER_RUN_SAPI_TESTS=1 is set.
"""

from __future__ import annotations

import math
import os
import struct
import subprocess
import sys
import tempfile
import unittest
import wave
from pathlib import Path
from unittest import mock

BACKEND_DIR = Path(__file__).resolve().parent.parent
SCRIPTS_DIR = BACKEND_DIR / "scripts"
sys.path.insert(0, str(SCRIPTS_DIR))

import audio_validation  # noqa: E402
import clone_peer  # noqa: E402
import stage_asset  # noqa: E402
import text_to_speech as tts  # noqa: E402


def write_wav(path: Path, samples: list[int], rate: int = 22050, channels: int = 1) -> None:
    with wave.open(str(path), "wb") as wav:
        wav.setnchannels(channels)
        wav.setsampwidth(2)
        wav.setframerate(rate)
        wav.writeframes(struct.pack(f"<{len(samples)}h", *samples))


def tone(seconds: float, amplitude: float = 0.5, rate: int = 22050) -> list[int]:
    return [
        int(amplitude * 32767 * math.sin(2 * math.pi * 220 * i / rate))
        for i in range(int(seconds * rate))
    ]


class AudioValidationTests(unittest.TestCase):
    def setUp(self) -> None:
        self._tmp = tempfile.TemporaryDirectory()
        self.dir = Path(self._tmp.name)

    def tearDown(self) -> None:
        self._tmp.cleanup()

    def test_valid_wav_is_recognized(self) -> None:
        path = self.dir / "ok.wav"
        write_wav(path, tone(1.0))
        report = audio_validation.validate_audio(path)
        self.assertTrue(report.ok, report.errors)
        self.assertEqual(report.format, "wav")
        self.assertEqual(report.analysis_level, "full")
        self.assertAlmostEqual(report.duration_seconds, 1.0, places=2)
        self.assertEqual(report.sample_rate, 22050)

    def test_missing_file_rejected(self) -> None:
        report = audio_validation.validate_audio(self.dir / "nope.wav")
        self.assertFalse(report.ok)
        self.assertIn("not found", report.errors[0].lower())

    def test_empty_file_rejected(self) -> None:
        path = self.dir / "empty.wav"
        path.write_bytes(b"")
        self.assertFalse(audio_validation.validate_audio(path).ok)

    def test_corrupt_wav_rejected(self) -> None:
        path = self.dir / "bad.wav"
        path.write_bytes(b"this is not audio" * 10)
        report = audio_validation.validate_audio(path)
        self.assertFalse(report.ok)

    def test_zero_frame_wav_rejected(self) -> None:
        path = self.dir / "zero.wav"
        write_wav(path, [])
        self.assertFalse(audio_validation.validate_audio(path).ok)

    def test_silent_wav_rejected(self) -> None:
        path = self.dir / "silent.wav"
        write_wav(path, [0] * 22050)
        report = audio_validation.validate_audio(path)
        self.assertFalse(report.ok)
        self.assertTrue(any("silent" in e.lower() for e in report.errors))

    def test_too_short_rejected(self) -> None:
        path = self.dir / "short.wav"
        write_wav(path, tone(0.05))
        self.assertFalse(audio_validation.validate_audio(path).ok)

    def test_clipping_warns_but_is_valid(self) -> None:
        path = self.dir / "clip.wav"
        write_wav(path, [32767 if i % 2 else -32768 for i in range(22050)])
        report = audio_validation.validate_audio(path)
        self.assertTrue(report.ok)
        self.assertTrue(any("clipping" in w.lower() for w in report.warnings))

    def test_long_leading_silence_warns(self) -> None:
        path = self.dir / "lead.wav"
        write_wav(path, [0] * 44100 + tone(1.0))
        report = audio_validation.validate_audio(path)
        self.assertTrue(report.ok)
        self.assertGreater(report.leading_silence_seconds, 0.9)
        self.assertTrue(any("leading" in w.lower() for w in report.warnings))

    def test_stereo_supported(self) -> None:
        path = self.dir / "stereo.wav"
        write_wav(path, [v for s in tone(0.5) for v in (s, s)], channels=2)
        report = audio_validation.validate_audio(path)
        self.assertTrue(report.ok)
        self.assertEqual(report.channels, 2)

    def test_unsupported_extension_rejected(self) -> None:
        path = self.dir / "x.ogg"
        path.write_bytes(b"OggS" + b"\x00" * 100)
        self.assertFalse(audio_validation.validate_audio(path).ok)

    def test_mp3_header_only_with_warning(self) -> None:
        path = self.dir / "a.mp3"
        path.write_bytes(b"ID3" + b"\x00" * 200)
        report = audio_validation.validate_audio(path)
        self.assertTrue(report.ok)
        self.assertEqual(report.analysis_level, "header-only")
        self.assertTrue(any("header" in w.lower() for w in report.warnings))

    def test_fake_mp3_rejected(self) -> None:
        path = self.dir / "fake.mp3"
        path.write_bytes(b"hello world" * 20)
        self.assertFalse(audio_validation.validate_audio(path).ok)


class TextToSpeechTests(unittest.TestCase):
    def setUp(self) -> None:
        self._tmp = tempfile.TemporaryDirectory()
        self.dir = Path(self._tmp.name)

    def tearDown(self) -> None:
        self._tmp.cleanup()

    def args(self, *extra: str) -> object:
        base = ["--output-file", str(self.dir / "out.wav")]
        return tts.parse_arguments(base + list(extra))

    def test_requires_authorization(self) -> None:
        a = self.args("--text", "hello")
        self.assertIn("ETHICS", tts.validate_parameters(a))

    def test_requires_text(self) -> None:
        a = self.args("--authorized-voice")
        self.assertIn("--text", tts.validate_parameters(a))

    def test_empty_text_rejected(self) -> None:
        a = self.args("--authorized-voice", "--text", "   ")
        self.assertIsNotNone(tts.validate_parameters(a))

    def test_rate_out_of_range_rejected(self) -> None:
        a = self.args("--authorized-voice", "--text", "hi", "--rate", "99")
        self.assertIn("--rate", tts.validate_parameters(a))

    def test_mp3_output_explained(self) -> None:
        a = tts.parse_arguments(
            ["--authorized-voice", "--text", "hi", "--output-file", str(self.dir / "o.mp3")]
        )
        self.assertIn("WAV only", tts.validate_parameters(a))

    def test_bad_extension_rejected(self) -> None:
        a = tts.parse_arguments(
            ["--authorized-voice", "--text", "hi", "--output-file", str(self.dir / "o.txt")]
        )
        self.assertIn("INVALID EXTENSION", tts.validate_parameters(a))

    def test_flutter_assets_output_refused(self) -> None:
        target = tts.FLUTTER_ASSETS_DIR / "audio" / "x.wav"
        a = tts.parse_arguments(
            ["--authorized-voice", "--text", "hi", "--output-file", str(target)]
        )
        self.assertIn("POLICY", tts.validate_parameters(a))

    def test_existing_output_requires_overwrite(self) -> None:
        (self.dir / "out.wav").write_bytes(b"x")
        a = self.args("--authorized-voice", "--text", "hi")
        self.assertIn("OUTPUT EXISTS", tts.validate_parameters(a))
        a = self.args("--authorized-voice", "--text", "hi", "--overwrite")
        self.assertIsNone(tts.validate_parameters(a))

    def test_dry_run_writes_nothing(self) -> None:
        a = self.args("--authorized-voice", "--text", "hi", "--dry-run")
        with mock.patch.object(tts, "synthesize") as synth:
            self.assertEqual(tts.run(a), 0)
            synth.assert_not_called()
        self.assertFalse((self.dir / "out.wav").exists())

    def test_resolve_voice_matching(self) -> None:
        installed = [("Microsoft David Desktop", "en-US"), ("Microsoft Zira Desktop", "en-US")]
        self.assertEqual(tts.resolve_voice("zira", installed), "Microsoft Zira Desktop")
        self.assertEqual(tts.resolve_voice("", installed), "")
        with self.assertRaises(ValueError):
            tts.resolve_voice("Nobody", installed)
        with self.assertRaises(ValueError):
            tts.resolve_voice("Microsoft", installed)

    def test_successful_generation_with_mock_engine(self) -> None:
        def fake_synth(text: str, voice: str, rate: int, destination: Path) -> None:
            write_wav(destination, tone(1.0))

        a = self.args("--authorized-voice", "--text", "hello there")
        with mock.patch.object(tts, "synthesize", side_effect=fake_synth):
            self.assertEqual(tts.run(a), 0)
        out = self.dir / "out.wav"
        self.assertTrue(out.exists())
        self.assertFalse((self.dir / "out.partial.wav").exists())
        self.assertTrue(audio_validation.validate_audio(out).ok)

    def test_engine_failure_returns_5_and_leaves_no_output(self) -> None:
        a = self.args("--authorized-voice", "--text", "hello")
        with mock.patch.object(tts, "synthesize", side_effect=tts.EngineError("boom")):
            self.assertEqual(tts.run(a), tts.EXIT_ENGINE)
        self.assertFalse((self.dir / "out.wav").exists())

    def test_silent_engine_output_rejected_and_cleaned_up(self) -> None:
        def silent(text: str, voice: str, rate: int, destination: Path) -> None:
            write_wav(destination, [0] * 22050)

        a = self.args("--authorized-voice", "--text", "hello")
        with mock.patch.object(tts, "synthesize", side_effect=silent):
            self.assertEqual(tts.run(a), tts.EXIT_OUTPUT_INVALID)
        self.assertFalse((self.dir / "out.wav").exists())
        self.assertFalse((self.dir / "out.partial.wav").exists())

    def test_failed_generation_does_not_clobber_existing_output(self) -> None:
        (self.dir / "out.wav").write_bytes(b"precious")
        a = self.args("--authorized-voice", "--text", "hello", "--overwrite")
        with mock.patch.object(tts, "synthesize", side_effect=tts.EngineError("boom")):
            tts.run(a)
        self.assertEqual((self.dir / "out.wav").read_bytes(), b"precious")

    @unittest.skipUnless(
        os.environ.get("GHOSTBUSTER_RUN_SAPI_TESTS") == "1" and os.name == "nt",
        "Optional Windows SAPI integration test (set GHOSTBUSTER_RUN_SAPI_TESTS=1).",
    )
    def test_real_sapi_generation(self) -> None:
        a = self.args("--authorized-voice", "--text", "This is a short test.")
        self.assertEqual(tts.run(a), 0)
        self.assertTrue(audio_validation.validate_audio(self.dir / "out.wav").ok)


class ClonePeerTests(unittest.TestCase):
    def test_not_implemented_exit_code_and_message(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            sample = Path(tmp) / "s.wav"
            write_wav(sample, tone(0.5))
            result = subprocess.run(
                [
                    sys.executable,
                    str(SCRIPTS_DIR / "clone_peer.py"),
                    "--sample-path",
                    str(sample),
                    "--speaker-name",
                    "Test",
                    "--authorized-consent",
                    "--output-dir",
                    str(Path(tmp) / "out"),
                ],
                capture_output=True,
                text=True,
            )
            self.assertEqual(result.returncode, clone_peer.EXIT_NOT_IMPLEMENTED)
            self.assertIn("NOT IMPLEMENTED", result.stderr)
            self.assertNotIn("SUCCESS", result.stdout)
            self.assertFalse((Path(tmp) / "out").exists())

    def test_dry_run_ok_and_creates_nothing(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            sample = Path(tmp) / "s.wav"
            write_wav(sample, tone(0.5))
            result = subprocess.run(
                [
                    sys.executable,
                    str(SCRIPTS_DIR / "clone_peer.py"),
                    "--sample-path",
                    str(sample),
                    "--speaker-name",
                    "Test",
                    "--authorized-consent",
                    "--dry-run",
                    "--output-dir",
                    str(Path(tmp) / "out"),
                ],
                capture_output=True,
                text=True,
            )
            self.assertEqual(result.returncode, 0)
            self.assertFalse((Path(tmp) / "out").exists())


class StageAssetTests(unittest.TestCase):
    def setUp(self) -> None:
        self._tmp = tempfile.TemporaryDirectory()
        self.dir = Path(self._tmp.name)
        self.assets = self.dir / "assets_audio"
        self.lib = self.dir / "lib"
        self.lib.mkdir()
        (self.lib / "x.dart").write_text("const a = 'assets/audio/peer_test.wav';")
        self.source = self.dir / "reviewed.wav"
        write_wav(self.source, tone(1.0))

    def tearDown(self) -> None:
        self._tmp.cleanup()

    def run_stage(self, *extra: str, name: str = "peer_test.wav", source: Path | None = None) -> int:
        argv = [
            "--source", str(source or self.source),
            "--target-name", name,
            "--approved-by", "Tester",
            "--license-note", "unit test",
            "--assets-dir", str(self.assets),
            "--lib-dir", str(self.lib),
        ] + list(extra)
        with mock.patch("sys.stderr"), mock.patch("sys.stdout"):
            return stage_asset.main(argv)

    def test_requires_listening_confirmation(self) -> None:
        self.assertEqual(self.run_stage(), 1)
        self.assertFalse(self.assets.exists())

    def test_stages_when_approved(self) -> None:
        self.assertEqual(self.run_stage("--confirm-listened"), 0)
        self.assertTrue((self.assets / "peer_test.wav").exists())

    def test_dry_run_copies_nothing(self) -> None:
        self.assertEqual(self.run_stage("--confirm-listened", "--dry-run"), 0)
        self.assertFalse((self.assets / "peer_test.wav").exists())

    def test_refuses_overwrite_without_flag(self) -> None:
        self.assets.mkdir()
        (self.assets / "peer_test.wav").write_bytes(b"old")
        self.assertEqual(self.run_stage("--confirm-listened"), 1)
        self.assertEqual((self.assets / "peer_test.wav").read_bytes(), b"old")
        self.assertEqual(self.run_stage("--confirm-listened", "--overwrite"), 0)

    def test_refuses_unreferenced_name(self) -> None:
        self.assertEqual(self.run_stage("--confirm-listened", name="other.wav"), 1)

    def test_refuses_extension_mismatch(self) -> None:
        (self.lib / "y.dart").write_text("'assets/audio/peer_test.mp3'")
        self.assertEqual(self.run_stage("--confirm-listened", name="peer_test.mp3"), 1)

    def test_refuses_invalid_audio(self) -> None:
        bad = self.dir / "bad.wav"
        bad.write_bytes(b"junk" * 50)
        self.assertEqual(self.run_stage("--confirm-listened", source=bad), 1)

    def test_refuses_unsafe_target_name(self) -> None:
        self.assertEqual(self.run_stage("--confirm-listened", name="Alice Smith.wav"), 1)

    def test_refuses_raw_voice_samples(self) -> None:
        raw = stage_asset.VOICE_SAMPLES_DIR / "__unit_test_tmp.wav"
        try:
            write_wav(raw, tone(1.0))
            self.assertEqual(self.run_stage("--confirm-listened", source=raw), 1)
        finally:
            raw.unlink(missing_ok=True)


if __name__ == "__main__":
    unittest.main()
