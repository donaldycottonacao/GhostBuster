"""Tests for AI Escape Script Generation and Presets."""

from __future__ import annotations

from fastapi.testclient import TestClient


def test_generate_script_english(client: TestClient) -> None:
    """Verify English script generation for party scenario."""
    payload = {
        "situation": "At a loud party and need to head home",
        "language": "en",
        "tone": "panicked",
    }
    response = client.post("/api/v1/scripts/generate", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["language"] == "en"
    assert "party" in data["generated_script"].lower() or "apartment" in data["generated_script"].lower()
    assert len(data["alternatives"]) > 0


def test_generate_script_tagalog(client: TestClient) -> None:
    """Verify Tagalog script generation."""
    payload = {
        "situation": "meeting sa opisina",
        "language": "tl",
        "tone": "urgent",
    }
    response = client.post("/api/v1/scripts/generate", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["language"] == "tl"
    assert any(w in data["generated_script"].lower() for w in ["opisina", "server", "emergency", "kailangan"])


def test_generate_script_cebuano(client: TestClient) -> None:
    """Verify Cebuano / Bisaya script generation."""
    payload = {
        "situation": "Naa ko sa party ug andam nang mouli",
        "language": "ceb",
        "tone": "panicked",
    }
    response = client.post("/api/v1/scripts/generate", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["language"] == "ceb"
    assert any(w in data["generated_script"].lower() for w in ["party", "tubo", "tubig", "mouli", "kinahanglan"])


def test_generate_script_validation_failure(client: TestClient) -> None:
    """Verify input validation fails on empty situation."""
    payload = {
        "situation": "",
        "language": "en",
    }
    response = client.post("/api/v1/scripts/generate", json=payload)
    assert response.status_code == 422


def test_generate_script_invalid_language(client: TestClient) -> None:
    """Verify request fails when an unsupported language code is provided."""
    payload = {
        "situation": "At a party",
        "language": "fr",
    }
    response = client.post("/api/v1/scripts/generate", json=payload)
    assert response.status_code == 422


def test_get_presets_all_languages(client: TestClient) -> None:
    """Verify presets endpoint returns templates for en, tl, and ceb."""
    for lang in ["en", "tl", "ceb"]:
        response = client.get(f"/api/v1/scripts/presets?language={lang}")
        assert response.status_code == 200
        data = response.json()
        assert len(data) >= 4
        assert all(item["language"] == lang for item in data)
