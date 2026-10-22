"""Escape Call Session Logging and Analytics Service."""

from __future__ import annotations

from typing import List, Optional, Dict, Any
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.models import EscapeSession
from app.schemas import SessionCreate


class SessionService:
    """Service managing escape session persistence and history."""

    @staticmethod
    def create(db: Session, data: SessionCreate) -> EscapeSession:
        """Record a completed or attempted escape call session."""
        session = EscapeSession(
            persona_id=data.persona_id,
            caller_name=data.caller_name,
            situation=data.situation,
            script=data.script,
            delay_seconds=data.delay_seconds,
            duration_seconds=data.duration_seconds,
            status=data.status,
            language=data.language,
        )
        db.add(session)
        db.commit()
        db.refresh(session)
        return session

    @staticmethod
    def get_all(db: Session, limit: int = 50, offset: int = 0) -> List[EscapeSession]:
        """Retrieve paginated session history ordered by recency."""
        return (
            db.query(EscapeSession)
            .order_by(EscapeSession.created_at.desc())
            .offset(offset)
            .limit(limit)
            .all()
        )

    @staticmethod
    def get_by_id(db: Session, session_id: str) -> Optional[EscapeSession]:
        """Find a session by its UUID."""
        return db.query(EscapeSession).filter(EscapeSession.id == session_id).first()

    @staticmethod
    def get_stats(db: Session) -> Dict[str, Any]:
        """Compute aggregated escape statistics."""
        total = db.query(EscapeSession).count()
        completed = db.query(EscapeSession).filter(EscapeSession.status == "completed").count()
        avg_duration = db.query(func.avg(EscapeSession.duration_seconds)).scalar() or 0.0

        return {
            "total_escapes": total,
            "completed_escapes": completed,
            "average_duration_seconds": round(float(avg_duration), 1),
        }
