"""Application Configuration Module."""

from __future__ import annotations

from pathlib import Path
from typing import List
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """GhostBuster backend settings loaded from environment or .env file."""

    app_name: str = "GhostBuster API"
    app_env: str = "development"
    debug: bool = True
    host: str = "0.0.0.0"
    port: int = 8000

    database_url: str = "sqlite:///./ghostbuster.db"
    api_prefix: str = "/api/v1"
    cors_origins: List[str] = ["*"]
    api_key: str = "ghostbuster-dev-secret-key"

    audio_output_dir: str = "../output_assets"

    model_config = SettingsConfigDict(
        env_file=str(Path(__file__).resolve().parent.parent / ".env"),
        env_file_encoding="utf-8",
        extra="ignore",
    )


settings = Settings()
