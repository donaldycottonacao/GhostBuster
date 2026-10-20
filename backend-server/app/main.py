"""GhostBuster Backend API Main Application."""

from __future__ import annotations

import logging
from contextlib import asynccontextmanager
from typing import AsyncGenerator
from fastapi import FastAPI, Request, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.config import settings
from app.database import init_db, SessionLocal
from app.services.persona_service import PersonaService
from app.routers import health, scripts, personas, sessions, audio

# Configure structured logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
)
logger = logging.getLogger("ghostbuster.api")


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator[None, None]:
    """Application lifespan context manager for startup and shutdown routines."""
    logger.info("Initializing GhostBuster database tables...")
    init_db()

    # Seed default personas on startup
    db = SessionLocal()
    try:
        PersonaService.seed_default_personas(db)
        logger.info("Default caller personas verified/seeded.")
    finally:
        db.close()

    logger.info("GhostBuster API initialized and ready on %s:%s", settings.host, settings.port)
    yield
    logger.info("GhostBuster API shutting down.")


app = FastAPI(
    title=settings.app_name,
    version="0.1.0",
    description="Backend API services supporting GhostBuster simulated escape calls, trilingual AI script generation, caller persona management, and audio synthesis.",
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json",
    lifespan=lifespan,
)

# Enable CORS for Flutter web, emulator (10.0.2.2), local devices, and browser preview
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Global exception handler for uncaught exceptions
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    logger.error("Unhandled error processing %s: %s", request.url.path, exc, exc_info=True)
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "error": "InternalServerError",
            "message": "An unexpected error occurred while processing the request.",
            "detail": str(exc) if settings.debug else None,
            "path": request.url.path,
        },
    )


# Mount routers
app.include_router(health.router)
app.include_router(scripts.router, prefix=settings.api_prefix)
app.include_router(personas.router, prefix=settings.api_prefix)
app.include_router(sessions.router, prefix=settings.api_prefix)
app.include_router(audio.router, prefix=settings.api_prefix)


@app.get("/")
def root_summary():
    """Root metadata discovery endpoint."""
    return {
        "app": settings.app_name,
        "status": "online",
        "documentation": "/docs",
        "endpoints": {
            "health": "/health",
            "scripts": f"{settings.api_prefix}/scripts/generate",
            "personas": f"{settings.api_prefix}/personas",
            "sessions": f"{settings.api_prefix}/sessions",
            "audio": f"{settings.api_prefix}/audio/synthesize",
        },
    }
