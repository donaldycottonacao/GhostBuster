"""Escape Session Logging and Metrics API Endpoints."""

from __future__ import annotations

from typing import List, Dict, Any
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.schemas import SessionCreate, SessionResponse
from app.services.session_service import SessionService

router = APIRouter(prefix="/sessions", tags=["Sessions"])


@router.post("", response_model=SessionResponse, status_code=status.HTTP_201_CREATED)
def record_session(data: SessionCreate, db: Session = Depends(get_db)) -> SessionResponse:
    """Record an escape call session execution (delay, duration, status, script)."""
    return SessionService.create(db, data)


@router.get("", response_model=List[SessionResponse])
def list_sessions(
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),
) -> List[SessionResponse]:
    """Retrieve history of recorded escape sessions."""
    return SessionService.get_all(db, limit=limit, offset=offset)


@router.get("/stats", response_model=Dict[str, Any])
def get_session_stats(db: Session = Depends(get_db)) -> Dict[str, Any]:
    """Get aggregated statistics on escapes orchestrated by GhostBuster."""
    return SessionService.get_stats(db)


@router.get("/{session_id}", response_model=SessionResponse)
def get_session(session_id: str, db: Session = Depends(get_db)) -> SessionResponse:
    """Retrieve details of a single escape session."""
    session = SessionService.get_by_id(db, session_id)
    if not session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Session '{session_id}' not found.",
        )
    return session
