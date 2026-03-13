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

test: deps
	$(PY) -m pytest --maxfail=1 --cov=app --cov-report=term-missing --cov-report=xml:coverage.xml --cov-report=json:coverage.json --html=report.html --self-contained-html tests

coverage: test
	$(PY) -m coverage html -d htmlcov

html: coverage
	@echo "HTML coverage available in htmlcov/index.html and flask_example/report.html"

clean:
	rm -rf htmlcov report.html coverage.xml coverage.json
