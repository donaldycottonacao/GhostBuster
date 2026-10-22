"""SQLAlchemy Domain Models for GhostBuster."""

from __future__ import annotations

import datetime
import uuid
from sqlalchemy import Column, String, Integer, DateTime, Boolean, Text
from app.database import Base


class Persona(Base):
    """Caller persona profile for simulated escape calls."""

    __tablename__ = "personas"

    id = Column(String(50), primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    number = Column(String(50), nullable=False)
    relationship = Column(String(100), default="Emergency contact")
    voice_style = Column(String(50), default="PANICKED")
    ringtone = Column(String(50), default="containment")
    audio_asset = Column(String(255), nullable=True)
    is_custom = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)


class EscapeSession(Base):
    """Log of simulated escape call sessions."""

    __tablename__ = "escape_sessions"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()), index=True)
    persona_id = Column(String(50), nullable=True)
    caller_name = Column(String(100), nullable=False)
    situation = Column(Text, nullable=True)
    script = Column(Text, nullable=False)
    delay_seconds = Column(Integer, default=30)
    duration_seconds = Column(Integer, default=0)
    status = Column(String(30), default="completed")  # scheduled, active, completed, declined, cancelled
    language = Column(String(10), default="en")
    created_at = Column(DateTime, default=datetime.datetime.utcnow)


class PresetScript(Base):
    """Curated AI and situation-specific emergency escape scripts."""

    __tablename__ = "preset_scripts"

    id = Column(Integer, primary_key=True, autoincrement=True)
    category = Column(String(50), index=True)  # party, meeting, date, family, generic
    situation = Column(String(255), nullable=False)
    language = Column(String(10), default="en", index=True)
    tone = Column(String(30), default="urgent")
    script_text = Column(Text, nullable=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
