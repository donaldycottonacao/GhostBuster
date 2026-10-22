"""Caller Persona Management Service."""

from __future__ import annotations

from typing import List, Optional
from sqlalchemy.orm import Session
from app.models import Persona
from app.schemas import PersonaCreate, PersonaUpdate


DEFAULT_PERSONAS = [
    {
        "id": "riley_morgan",
        "name": "Riley Morgan",
        "number": "+1 (555) 019-2834",
        "relationship": "Emergency contact",
        "voice_style": "PANICKED",
        "ringtone": "containment",
        "audio_asset": "assets/audio/peer_mom.mp3",
        "is_custom": False,
    },
    {
        "id": "mom",
        "name": "Mom",
        "number": "+1 (555) 234-5678",
        "relationship": "Mother",
        "voice_style": "WORRIED",
        "ringtone": "containment",
        "audio_asset": "assets/audio/peer_mom.mp3",
        "is_custom": False,
    },
    {
        "id": "landlord",
        "name": "Landlord (Maintenance)",
        "number": "+1 (555) 876-5432",
        "relationship": "Property Manager",
        "voice_style": "URGENT",
        "ringtone": "soft",
        "audio_asset": "assets/audio/peer_landlord.mp3",
        "is_custom": False,
    },
    {
        "id": "work_boss",
        "name": "Office Dispatch",
        "number": "+1 (555) 432-1098",
        "relationship": "Workplace Support",
        "voice_style": "CALM & DIRECT",
        "ringtone": "classic",
        "audio_asset": None,
        "is_custom": False,
    },
]


class PersonaService:
    """Service handling caller persona persistence and operations."""

    @staticmethod
    def seed_default_personas(db: Session) -> None:
        """Populate database with default personas if table is empty."""
        count = db.query(Persona).count()
        if count == 0:
            for item in DEFAULT_PERSONAS:
                persona = Persona(**item)
                db.add(persona)
            db.commit()

    @staticmethod
    def get_all(db: Session) -> List[Persona]:
        """Retrieve all personas."""
        return db.query(Persona).order_by(Persona.created_at.asc()).all()

    @staticmethod
    def get_by_id(db: Session, persona_id: str) -> Optional[Persona]:
        """Find a persona by its string ID."""
        return db.query(Persona).filter(Persona.id == persona_id).first()

    @staticmethod
    def create(db: Session, data: PersonaCreate) -> Persona:
        """Create a new custom persona."""
        persona = Persona(
            id=data.id,
            name=data.name,
            number=data.number,
            relationship=data.relationship,
            voice_style=data.voice_style,
            ringtone=data.ringtone,
            audio_asset=data.audio_asset,
            is_custom=True,
        )
        db.add(persona)
        db.commit()
        db.refresh(persona)
        return persona

    @staticmethod
    def update(db: Session, persona: Persona, data: PersonaUpdate) -> Persona:
        """Update fields of an existing persona."""
        if data.name is not None:
            persona.name = data.name
        if data.number is not None:
            persona.number = data.number
        if data.relationship is not None:
            persona.relationship = data.relationship
        if data.voice_style is not None:
            persona.voice_style = data.voice_style
        if data.ringtone is not None:
            persona.ringtone = data.ringtone
        if data.audio_asset is not None:
            persona.audio_asset = data.audio_asset

        db.commit()
        db.refresh(persona)
        return persona

    @staticmethod
    def delete(db: Session, persona: Persona) -> None:
        """Delete a persona."""
        db.delete(persona)
        db.commit()
