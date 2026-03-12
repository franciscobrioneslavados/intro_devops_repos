import inspect
import pathlib
import sys

workspace_root = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(workspace_root))

from app import app


def test_home_page():
    client = app.test_client()
    response = client.get('/')
    assert response.status_code == 200
    assert b'Hola desde Flask' in response.data
