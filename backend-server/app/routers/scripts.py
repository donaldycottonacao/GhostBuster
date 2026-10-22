"""AI Escape Script Generation and Presets Endpoints."""

from __future__ import annotations

from typing import List, Dict, Any
from fastapi import APIRouter, Query
from app.schemas import ScriptGenerateRequest, ScriptGenerateResponse
from app.services.script_service import ScriptService

router = APIRouter(prefix="/scripts", tags=["Scripts"])


@router.post("/generate", response_model=ScriptGenerateResponse)
def generate_escape_script(request: ScriptGenerateRequest) -> ScriptGenerateResponse:
    """Generate dynamic simulated escape dialogue tailored to situation, language, and tone."""
    return ScriptService.generate(request)


@router.get("/presets", response_model=List[Dict[str, Any]])
def get_preset_scripts(language: str = Query("en", pattern="^(en|tl|ceb)$")) -> List[Dict[str, Any]]:
    """Retrieve curated emergency situations and dialogues for a given language."""
    categories = ["party", "meeting", "date", "generic"]
    presets = []

    for cat in categories:
        req = ScriptGenerateRequest(situation=cat, language=language, tone="urgent")
        res = ScriptService.generate(req)
        presets.append({
            "category": cat,
            "situation": cat.capitalize(),
            "language": language,
            "primary_script": res.generated_script,
            "alternatives": res.alternatives,
        })

    return presets
