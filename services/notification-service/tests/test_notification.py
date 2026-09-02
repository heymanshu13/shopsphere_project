from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


def test_health():
    response = client.get("/health")

    assert response.status_code == 200


def test_notification():
    response = client.post("/notifications")

    assert response.status_code == 200

    data = response.json()

    assert data["status"] == "SENT"
