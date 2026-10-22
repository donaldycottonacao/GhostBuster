"""Tests for Audio Synthesis and Track Listing."""

from __future__ import annotations

from fastapi.testclient import TestClient


def test_audio_synthesize_rejects_without_authorization(client: TestClient) -> None:
    """Verify synthesis is rejected with 403 when consent confirmation is false."""
    payload = {
        "text": "Emergency escape dialogue",
        "voice_model": "default_escort",
        "authorized_voice": False,
    }
    response = client.post("/api/v1/audio/synthesize", json=payload)
    assert response.status_code == 403
    assert "authorization consent" in response.json()["detail"].lower()


def test_audio_synthesize_dry_run_success(client: TestClient) -> None:
    """Verify synthesis succeeds with authorized voice."""
    payload = {
        "text": "Hey, there is an urgent water leak in the apartment! Please call back immediately.",
        "voice_model": "landlord",
        "authorized_voice": True,
        "output_filename": "test_peer_landlord.mp3",
    }
    response = client.post("/api/v1/audio/synthesize", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "success"
    assert data["voice_model"] == "landlord"
    assert "audio_url" in data
    assert data["duration_seconds"] > 0


def test_list_audio_tracks(client: TestClient) -> None:
    """Verify audio tracks endpoint returns default and assets tracks."""
    response = client.get("/api/v1/audio/tracks")
    assert response.status_code == 200
    tracks = response.json()
    assert len(tracks) >= 4
    filenames = [t["filename"] for t in tracks]
    assert "ringtone_ios.mp3" in filenames
    assert "peer_mom.mp3" in filenames
