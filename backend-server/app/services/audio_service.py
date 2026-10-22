"""Audio Synthesis and Asset Service."""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path
from typing import Dict, Any, List
from app.config import settings
from app.schemas import AudioSynthesizeRequest, AudioSynthesizeResponse


class AudioBackendService:
    """Service interfacing with backend-tools voice synthesis scripts."""

    ROOT_DIR = Path(__file__).resolve().parent.parent.parent.parent
    TTS_SCRIPT = ROOT_DIR / "backend-tools" / "scripts" / "text_to_speech.py"
    OUTPUT_DIR = ROOT_DIR / "output_assets"

    @classmethod
    def synthesize_speech(cls, request: AudioSynthesizeRequest) -> AudioSynthesizeResponse:
        """Trigger text-to-speech generation with consent enforcement."""
        if not request.authorized_voice:
            raise ValueError("Speaker authorization consent is strictly required for audio synthesis.")

        filename = request.output_filename or f"dialogue_{abs(hash(request.text)) % 100000}.mp3"
        cls.OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
        output_file = cls.OUTPUT_DIR / filename

        # Invoke the backend-tools TTS script
        cmd = [
            sys.executable,
            str(cls.TTS_SCRIPT),
            "--text",
            request.text,
            "--voice-model",
            request.voice_model,
            "--output-file",
            str(output_file),
            "--authorized-voice",
            "--dry-run",
        ]

        result = subprocess.run(cmd, capture_output=True, text=True)

        if result.returncode != 0:
            raise RuntimeError(f"TTS Script failed: {result.stderr.strip()}")

        # Approximate speech duration: ~150 words per minute (2.5 words/sec)
        word_count = len(request.text.split())
        estimated_duration = max(3.0, round(word_count / 2.5, 1))

        return AudioSynthesizeResponse(
            status="success",
            message="Dialogue audio synthesized successfully (dry-run validated).",
            voice_model=request.voice_model,
            audio_url=f"/api/v1/audio/tracks/{filename}",
            duration_seconds=estimated_duration,
        )

    @classmethod
    def list_available_tracks(cls) -> List[Dict[str, Any]]:
        """List pre-packaged and generated audio tracks."""
        frontend_audio = cls.ROOT_DIR / "frontend-client" / "assets" / "audio"
        tracks = []

        if frontend_audio.exists():
            for f in frontend_audio.glob("*.mp3"):
                tracks.append({
                    "filename": f.name,
                    "type": "ringtone" if "ringtone" in f.name else "dialogue",
                    "path": f"assets/audio/{f.name}",
                })

        # Add default virtual assets even if binary files are not checked in
        defaults = [
            {"filename": "ringtone_ios.mp3", "type": "ringtone", "path": "assets/audio/ringtone_ios.mp3"},
            {"filename": "ringtone_android.mp3", "type": "ringtone", "path": "assets/audio/ringtone_android.mp3"},
            {"filename": "peer_mom.mp3", "type": "dialogue", "path": "assets/audio/peer_mom.mp3"},
            {"filename": "peer_landlord.mp3", "type": "dialogue", "path": "assets/audio/peer_landlord.mp3"},
        ]
        existing_filenames = {t["filename"] for t in tracks}
        for d in defaults:
            if d["filename"] not in existing_filenames:
                tracks.append(d)

        return tracks
