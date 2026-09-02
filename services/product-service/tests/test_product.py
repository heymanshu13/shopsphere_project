from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


def test_health():
    response = client.get("/health")

    assert response.status_code == 200


def test_products():
    response = client.get("/products")

    assert response.status_code == 200

    products = response.json()

    assert len(products) >= 1
