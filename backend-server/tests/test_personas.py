"""Tests for Caller Persona Endpoints."""

from __future__ import annotations

from fastapi.testclient import TestClient


def test_list_personas_returns_defaults(client: TestClient) -> None:
    """Verify default seeded personas are returned in list."""
    response = client.get("/api/v1/personas")
    assert response.status_code == 200
    personas = response.json()
    assert len(personas) >= 4
    ids = [p["id"] for p in personas]
    assert "mom" in ids
    assert "riley_morgan" in ids
    assert "landlord" in ids
    assert "work_boss" in ids


def test_get_persona_by_id(client: TestClient) -> None:
    """Verify single persona lookup by ID."""
    response = client.get("/api/v1/personas/riley_morgan")
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "Riley Morgan"
    assert data["relationship"] == "Emergency contact"


def test_get_persona_not_found(client: TestClient) -> None:
    """Verify 404 is returned for non-existent persona."""
    response = client.get("/api/v1/personas/non_existent_persona")
    assert response.status_code == 404


def test_create_custom_persona(client: TestClient) -> None:
    """Verify creating a custom caller persona."""
    payload = {
        "id": "doctor_smith",
        "name": "Dr. Smith (Clinic)",
        "number": "+1 (555) 765-4321",
        "relationship": "Physician",
        "voice_style": "CLINICAL",
        "ringtone": "soft",
    }
    response = client.post("/api/v1/personas", json=payload)
    assert response.status_code == 201
    data = response.json()
    assert data["id"] == "doctor_smith"
    assert data["name"] == "Dr. Smith (Clinic)"
    assert data["is_custom"] is True


def test_create_duplicate_persona_conflict(client: TestClient) -> None:
    """Verify 409 Conflict when attempting to create duplicate persona ID."""
    payload = {
        "id": "mom",
        "name": "Duplicate Mom",
        "number": "+1 (555) 000-0000",
    }
    response = client.post("/api/v1/personas", json=payload)
    assert response.status_code == 409


def test_update_persona(client: TestClient) -> None:
    """Verify updating persona fields."""
    update_payload = {"name": "Mother Dearest", "relationship": "Super Mom"}
    response = client.put("/api/v1/personas/mom", json=update_payload)
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "Mother Dearest"
    assert data["relationship"] == "Super Mom"


def test_delete_default_persona_prohibited(client: TestClient) -> None:
    """Verify default built-in personas cannot be deleted."""
    response = client.delete("/api/v1/personas/mom")
    assert response.status_code == 400
    assert "built-in" in response.json()["detail"].lower()
