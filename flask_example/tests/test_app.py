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

def test_sum_endpoint():
    client = app.test_client()
    response = client.get('/sum?a=4&b=2')
    assert response.status_code == 200
    payload = response.get_json()
    assert payload == {'result': 6.0}

def test_subtract_endpoint():
    client = app.test_client()
    response = client.get('/subtract?a=10&b=3')
    assert response.status_code == 200
    payload = response.get_json()
    assert payload == {'result': 7.0}
