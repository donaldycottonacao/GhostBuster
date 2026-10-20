#!/usr/bin/env python3
"""Runner script for GhostBuster Backend Server."""

from __future__ import annotations

import uvicorn
from app.config import settings


def main() -> None:
    """Run uvicorn server with application settings."""
    uvicorn.run(
        "app.main:app",
        host=settings.host,
        port=settings.port,
        reload=settings.debug,
    )


if __name__ == "__main__":
    main()
