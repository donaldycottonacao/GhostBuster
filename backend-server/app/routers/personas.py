"""Caller Personas API Endpoints."""

from __future__ import annotations

from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.schemas import PersonaCreate, PersonaUpdate, PersonaResponse
from app.services.persona_service import PersonaService

router = APIRouter(prefix="/personas", tags=["Personas"])


@router.get("", response_model=List[PersonaResponse])
def list_personas(db: Session = Depends(get_db)) -> List[PersonaResponse]:
    """List all caller personas available for simulated calls."""
    PersonaService.seed_default_personas(db)
    return PersonaService.get_all(db)


@router.post("", response_model=PersonaResponse, status_code=status.HTTP_201_CREATED)
def create_persona(data: PersonaCreate, db: Session = Depends(get_db)) -> PersonaResponse:
    """Create a new custom caller persona."""
    existing = PersonaService.get_by_id(db, data.id)
    if existing:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"Persona with ID '{data.id}' already exists.",
        )
    return PersonaService.create(db, data)


@router.get("/{persona_id}", response_model=PersonaResponse)
def get_persona(persona_id: str, db: Session = Depends(get_db)) -> PersonaResponse:
    """Get details of a specific caller persona."""
    persona = PersonaService.get_by_id(db, persona_id)
    if not persona:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Persona '{persona_id}' not found.",
        )
    return persona


@router.put("/{persona_id}", response_model=PersonaResponse)
def update_persona(persona_id: str, data: PersonaUpdate, db: Session = Depends(get_db)) -> PersonaResponse:
    """Update caller persona details."""
    persona = PersonaService.get_by_id(db, persona_id)
    if not persona:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Persona '{persona_id}' not found.",
        )
    return PersonaService.update(db, persona, data)


@router.delete("/{persona_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_persona(persona_id: str, db: Session = Depends(get_db)) -> None:
    """Delete a custom caller persona."""
    persona = PersonaService.get_by_id(db, persona_id)
    if not persona:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Persona '{persona_id}' not found.",
        )
    if not persona.is_custom:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Built-in default personas cannot be deleted.",
        )
    PersonaService.delete(db, persona)
