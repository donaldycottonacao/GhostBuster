"""Pydantic Request and Response Schemas."""

from __future__ import annotations

import datetime
from typing import List, Optional
from pydantic import BaseModel, Field


# ---------------------------------------------------------------------------
# Health Schemas
# ---------------------------------------------------------------------------
class HealthResponse(BaseModel):
    status: str = "ok"
    app_name: str
    version: str
    environment: str
    database: str
    timestamp: datetime.datetime


# ---------------------------------------------------------------------------
# Script Generation Schemas
# ---------------------------------------------------------------------------
class ScriptGenerateRequest(BaseModel):
    situation: str = Field(..., min_length=2, max_length=500, description="Context or scenario triggering the escape")
    language: str = Field(default="en", pattern="^(en|tl|ceb)$", description="Language code: en, tl, or ceb")
    tone: str = Field(default="panicked", description="Dialogue tone: panicked, urgent, casual, or formal")


class ScriptGenerateResponse(BaseModel):
    situation: str
    language: str
    tone: str
    generated_script: str
    alternatives: List[str] = []


# ---------------------------------------------------------------------------
# Persona Schemas
# ---------------------------------------------------------------------------
class PersonaBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    number: str = Field(..., min_length=3, max_length=50)
    relationship: str = Field(default="Emergency contact", max_length=100)
    voice_style: str = Field(default="PANICKED", max_length=50)
    ringtone: str = Field(default="containment", max_length=50)
    audio_asset: Optional[str] = None


class PersonaCreate(PersonaBase):
    id: str = Field(..., min_length=1, max_length=50, pattern="^[a-zA-Z0-9_-]+$")


class PersonaUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    number: Optional[str] = Field(None, min_length=3, max_length=50)
    relationship: Optional[str] = None
    voice_style: Optional[str] = None
    ringtone: Optional[str] = None
    audio_asset: Optional[str] = None


class PersonaResponse(PersonaBase):
    id: str
    is_custom: bool
    created_at: datetime.datetime

    model_config = {"from_attributes": True}


# ---------------------------------------------------------------------------
# Session Logging Schemas
# ---------------------------------------------------------------------------
class SessionCreate(BaseModel):
    persona_id: Optional[str] = None
    caller_name: str = Field(..., min_length=1, max_length=100)
    situation: Optional[str] = None
    script: str = Field(..., min_length=1)
    delay_seconds: int = Field(default=30, ge=0)
    duration_seconds: int = Field(default=0, ge=0)
    status: str = Field(default="completed")
    language: str = Field(default="en", pattern="^(en|tl|ceb)$")


class SessionResponse(BaseModel):
    id: str
    persona_id: Optional[str]
    caller_name: str
    situation: Optional[str]
    script: str
    delay_seconds: int
    duration_seconds: int
    status: str
    language: str
    created_at: datetime.datetime

    model_config = {"from_attributes": True}


# ---------------------------------------------------------------------------
# Audio Synthesis Schemas
# ---------------------------------------------------------------------------
class AudioSynthesizeRequest(BaseModel):
    text: str = Field(..., min_length=3, max_length=1000)
    voice_model: str = Field(default="default_escort")
    authorized_voice: bool = Field(default=True, description="Legal confirmation of speaker consent")
    output_filename: Optional[str] = None


class AudioSynthesizeResponse(BaseModel):
    status: str
    message: str
    voice_model: str
    audio_url: str
    duration_seconds: float
