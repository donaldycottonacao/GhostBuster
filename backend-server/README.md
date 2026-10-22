# GhostBuster Backend Server

The **GhostBuster Backend Server** is a fast, lightweight, offline-first Python FastAPI service that supports the GhostBuster Flutter client with trilingual AI script generation, caller persona management, session logging, and audio synthesis.

---

## Features

- **Trilingual AI Script Generation**: Generates contextual, convincing simulated escape call dialogues in **English (`en`)**, **Tagalog (`tl`)**, and **Cebuano / Bisaya (`ceb`)**.
- **Caller Persona Management**: Persists caller profiles (`Mom`, `Riley Morgan`, `Landlord`, `Office Dispatch`) with phone numbers, voice style, and custom avatars.
- **Escape Session History**: Records duration, situation, selected persona, and completion analytics.
- **Voice Synthesis Integration**: Bridges with `backend-tools` text-to-speech engine with mandatory speaker authorization consent checks.
- **Health Checks & Monitoring**: `/health` and `/api/v1/health` providing database and service status.
- **Interactive Documentation**: Auto-generated Swagger UI at `/docs` and ReDoc at `/redoc`.

---

## Directory Structure

```text
backend-server/
├── .env.example              # Environment variables template
├── .gitignore                # Ignore rules for virtual environment and SQLite
├── requirements.txt          # Python dependencies
├── run.py                    # Server startup script
├── app/
│   ├── __init__.py
│   ├── config.py             # Pydantic settings
│   ├── database.py           # SQLite connection and session management
│   ├── models.py             # SQLAlchemy domain entities
│   ├── schemas.py            # Pydantic request/response validation schemas
│   ├── main.py               # FastAPI app, CORS, error handling, lifespan
│   ├── services/
│   │   ├── script_service.py # Trilingual AI dialogue generator
│   │   ├── persona_service.py# Persona CRUD and default seeding
│   │   ├── session_service.py# Session logs and metrics
│   │   └── audio_service.py  # Audio synthesis and track discovery
│   └── routers/
│       ├── health.py         # /health and /api/v1/health
│       ├── scripts.py        # /api/v1/scripts/generate & presets
│       ├── personas.py       # /api/v1/personas CRUD
│       ├── sessions.py       # /api/v1/sessions logging
│       └── audio.py          # /api/v1/audio/synthesize
└── tests/
    ├── conftest.py           # In-memory SQLite and TestClient fixtures
    ├── test_health.py        # Health endpoint tests
    ├── test_scripts.py       # Trilingual script generation tests
    ├── test_personas.py      # Persona CRUD tests
    ├── test_sessions.py      # Session logging & stats tests
    └── test_audio.py         # Audio synthesis tests
```

---

## Quickstart

### 1. Set Up Virtual Environment

- **Windows (PowerShell):**
  ```powershell
  cd backend-server
  python -m venv .venv
  .\.venv\Scripts\Activate.ps1
  pip install -r requirements.txt
  ```

- **macOS / Linux:**
  ```bash
  cd backend-server
  python3 -m venv .venv
  source .venv/bin/activate
  pip install -r requirements.txt
  ```

### 2. Configure Environment

```bash
copy .env.example .env   # Windows
cp .env.example .env     # macOS / Linux
```

### 3. Run Automated Tests

```bash
pytest tests -v
```

### 4. Start Development Server

```bash
python run.py
```
Or via Uvicorn:
```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

Interactive API documentation will be available at:
- **Swagger UI**: `http://127.0.0.1:8000/docs`
- **ReDoc**: `http://127.0.0.1:8000/redoc`

---

## API Endpoints Reference

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/health` | Service health and DB status |
| `GET` | `/api/v1/health` | Service health (versioned) |
| `POST` | `/api/v1/scripts/generate` | Generate trilingual escape script |
| `GET` | `/api/v1/scripts/presets` | Get preset emergency scenarios |
| `GET` | `/api/v1/personas` | List caller personas |
| `POST` | `/api/v1/personas` | Create custom caller persona |
| `GET` | `/api/v1/personas/{id}` | Get persona by ID |
| `PUT` | `/api/v1/personas/{id}` | Update persona details |
| `DELETE`| `/api/v1/personas/{id}` | Delete custom persona |
| `POST` | `/api/v1/sessions` | Record escape call session |
| `GET` | `/api/v1/sessions` | List recorded sessions |
| `GET` | `/api/v1/sessions/stats` | Aggregated escape metrics |
| `POST` | `/api/v1/audio/synthesize` | Text-to-speech dialogue synthesis |
| `GET` | `/api/v1/audio/tracks` | List available audio tracks |
