"""Tests for Escape Session Logging and Statistics Endpoints."""

from __future__ import annotations

from fastapi.testclient import TestClient


def test_record_and_get_session(client: TestClient) -> None:
    """Verify recording and fetching an escape call session."""
    payload = {
        "persona_id": "riley_morgan",
        "caller_name": "Riley Morgan",
        "situation": "Awkward networking event",
        "script": "Hey, can you call me? I need a reason to step out.",
        "delay_seconds": 30,
        "duration_seconds": 18,
        "status": "completed",
        "language": "en",
    }
    response = client.post("/api/v1/sessions", json=payload)
    assert response.status_code == 201
    created = response.json()
    assert "id" in created
    assert created["duration_seconds"] == 18
    assert created["caller_name"] == "Riley Morgan"

    session_id = created["id"]
    get_res = client.get(f"/api/v1/sessions/{session_id}")
    assert get_res.status_code == 200
    assert get_res.json()["id"] == session_id


def test_list_sessions_pagination(client: TestClient) -> None:
    """Verify session list pagination."""
    for i in range(3):
        client.post("/api/v1/sessions", json={
            "caller_name": f"Caller {i}",
            "script": "Quick escape call",
            "duration_seconds": 10 + i,
        })

    response = client.get("/api/v1/sessions?limit=2&offset=0")
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 2


def test_session_stats(client: TestClient) -> None:
    """Verify stats computation calculates totals and average duration."""
    client.post("/api/v1/sessions", json={
        "caller_name": "Test Caller 1",
        "script": "Script 1",
        "duration_seconds": 20,
        "status": "completed",
    })
    client.post("/api/v1/sessions", json={
        "caller_name": "Test Caller 2",
        "script": "Script 2",
        "duration_seconds": 40,
        "status": "completed",
    })

    response = client.get("/api/v1/sessions/stats")
    assert response.status_code == 200
    stats = response.json()
    assert stats["total_escapes"] >= 2
    assert stats["completed_escapes"] >= 2
    assert stats["average_duration_seconds"] > 0
