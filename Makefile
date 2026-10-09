VENV = .venv
PYTHON = $(VENV)/bin/python
PYTEST = $(VENV)/bin/pytest

.PHONY: install test test-api test-ui test-smoke test-perf report

install:
	python3 -m venv $(VENV)
	$(PYTHON) -m pip install -r requirements.txt
	$(PYTHON) -m playwright install chromium

test:
	$(PYTEST)

test-api:
	$(PYTEST) -m api

test-ui:
	$(PYTEST) -m ui

test-smoke:
	$(PYTEST) -m smoke

# Load test with Locust (starts its own mock app, takes about 30 seconds)
test-perf:
	performance/run_perf.sh

# Open the HTML report (macOS: open, Linux: xdg-open)
report:
	open reports/report.html || xdg-open reports/report.html
