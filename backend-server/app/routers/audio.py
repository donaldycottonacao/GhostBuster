"""Audio Synthesis and Tracks API Endpoints."""

from __future__ import annotations

from typing import List, Dict, Any
from fastapi import APIRouter, HTTPException, status
from app.schemas import AudioSynthesizeRequest, AudioSynthesizeResponse
from app.services.audio_service import AudioBackendService

router = APIRouter(prefix="/audio", tags=["Audio"])


@router.post("/synthesize", response_model=AudioSynthesizeResponse)
def synthesize_audio(request: AudioSynthesizeRequest) -> AudioSynthesizeResponse:
    """Synthesize escape dialogue audio via the backend tools TTS pipeline with consent checks."""
    try:
        return AudioBackendService.synthesize_speech(request)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))


@router.get("/tracks", response_model=List[Dict[str, Any]])
def list_tracks() -> List[Dict[str, Any]]:
    """List pre-packaged and generated ringtones and dialogue audio tracks."""
    return AudioBackendService.list_available_tracks()
