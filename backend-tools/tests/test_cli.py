#!/usr/bin/env python3
"""Lightweight CLI smoke tests for GhostBuster backend tools.

Validates parameter checks, explicit consent enforcement, and dry-run execution.
"""

from __future__ import annotations

import subprocess
import sys
import unittest
from pathlib import Path

BACKEND_DIR = Path(__file__).resolve().parent.parent
SCRIPTS_DIR = BACKEND_DIR / "scripts"


class TestGhostBusterBackendCLI(unittest.TestCase):
    """Test suite validating CLI execution and security checks."""

    def test_clone_peer_missing_consent(self) -> None:
        """Verify clone_peer.py halts if explicit consent flag is omitted."""
        cmd = [
            sys.executable,
            str(SCRIPTS_DIR / "clone_peer.py"),
            "--sample-path",
            str(BACKEND_DIR / "voice_samples" / ".gitkeep"),
            "--speaker-name",
            "Alex",
        ]
        result = subprocess.run(cmd, capture_output=True, text=True)
        self.assertEqual(result.returncode, 1)
        self.assertIn("SECURITY & ETHICS ERROR", result.stderr)

    def test_clone_peer_missing_file(self) -> None:
        """Verify clone_peer.py reports missing audio files cleanly."""
        cmd = [
            sys.executable,
            str(SCRIPTS_DIR / "clone_peer.py"),
            "--sample-path",
            str(BACKEND_DIR / "voice_samples" / "non_existent_file.wav"),
            "--speaker-name",
            "Alex",
            "--authorized-consent",
        ]
        result = subprocess.run(cmd, capture_output=True, text=True)
        self.assertEqual(result.returncode, 1)
        self.assertIn("FILE NOT FOUND", result.stderr)

    def test_text_to_speech_missing_authorization(self) -> None:
        """Verify text_to_speech.py halts if authorization flag is omitted."""
        cmd = [
            sys.executable,
            str(SCRIPTS_DIR / "text_to_speech.py"),
            "--text",
            "Emergency dialogue notice",
        ]
        result = subprocess.run(cmd, capture_output=True, text=True)
        self.assertEqual(result.returncode, 1)
        self.assertIn("ETHICS & LICENSING ERROR", result.stderr)

    def test_text_to_speech_dry_run(self) -> None:
        """Verify text_to_speech.py passes pre-flight checks in dry-run mode."""
        cmd = [
            sys.executable,
            str(SCRIPTS_DIR / "text_to_speech.py"),
            "--text",
            "Emergency dialogue notice",
            "--authorized-voice",
            "--dry-run",
        ]
        result = subprocess.run(cmd, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0)
        self.assertIn("Dry run complete", result.stdout)


if __name__ == "__main__":
    unittest.main()
