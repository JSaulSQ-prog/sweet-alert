from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


def test_frontend_home_served():
    response = client.get("/")
    assert response.status_code == 200
    assert "Sweet Alert" in response.text
