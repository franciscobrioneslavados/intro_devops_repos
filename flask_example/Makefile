PYTHON ?= python3
VENV ?= venv
PIP := $(VENV)/bin/pip
PY := $(VENV)/bin/python

all: test

$(VENV)/bin/activate: $(VENV)

$(VENV):
\t$(PYTHON) -m venv $(VENV)

.PHONY: deps test coverage html clean

deps: $(VENV)
\t$(PIP) install --upgrade pip
\t$(PIP) install -r requirements.txt

test: deps
\t$(PY) -m pytest --maxfail=1 --cov=app --cov-report=term-missing --cov-report=xml:coverage.xml --cov-report=json:coverage.json --html=report.html --self-contained-html tests

coverage: test
\t$(PY) -m coverage html -d htmlcov

html: coverage
\t@echo "HTML coverage available in htmlcov/index.html and flask_example/report.html"

clean:
\trm -rf htmlcov report.html coverage.xml coverage.json
