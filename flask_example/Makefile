PYTHON ?= python3
VENV ?= venv
PIP := $(VENV)/bin/pip
PY := $(VENV)/bin/python

all: test

$(VENV)/bin/activate: $(VENV)

$(VENV):
	$(PYTHON) -m venv $(VENV)

.PHONY: deps test coverage html clean

deps: $(VENV)
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements.txt

run: deps
	$(PY) app.py

test: deps
	$(PY) -m pytest --maxfail=1 --cov=app --cov-report=term-missing --cov-report=xml:coverage.xml --cov-report=json:coverage.json tests

coverage: test
	$(PY) -m coverage html -d htmlcov

clean:
	rm -rf htmlcov report.html coverage.xml coverage.json
