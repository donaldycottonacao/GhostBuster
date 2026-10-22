"""Unit and Integration Tests for Health Endpoints."""

from __future__ import annotations

from fastapi.testclient import TestClient


def test_root_endpoint(client: TestClient) -> None:
    """Verify root discovery endpoint responds with online status."""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "online"
    assert "endpoints" in data


def test_health_endpoint(client: TestClient) -> None:
    """Verify /health endpoint returns healthy database connection."""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
    assert data["database"] == "connected"
    assert "timestamp" in data


def test_api_v1_health_endpoint(client: TestClient) -> None:
    """Verify /api/v1/health alias endpoint returns identical health response."""
    response = client.get("/api/v1/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
    assert data["app_name"] == "GhostBuster API"
