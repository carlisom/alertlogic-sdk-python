.PHONY: clean clean-build clean-pyc clean-test docs help
.DEFAULT_GOAL := help

define BROWSER_PYSCRIPT
import os, webbrowser, sys

from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
    match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
    if match:
        target, help = match.groups()
        print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

PYTHON := python
BROWSER := $(PYTHON) -c "$$BROWSER_PYSCRIPT"
PIP := pip

help:
	@$(PYTHON) -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

clean: clean-build clean-pyc clean-test ## remove all build, test, coverage and Python artifacts

clean-build: ## remove build artifacts
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +

clean-pyc: ## remove Python file artifacts
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

clean-test: ## remove test and coverage artifacts
	rm -fr .tox/
	rm -f .coverage
	rm -fr htmlcov/
	rm -fr .pytest_cache

lint: ## check style with flake8
	flake8 almdrlib tests

test: ## run tests quickly with the default Python
	$(PYTHON) setup.py test
	
test-all: ## run tests on every Python version with tox
	tox

coverage: ## check code coverage quickly with the default Python
	coverage run --source almdrlib setup.py test
	coverage report -m
	coverage html
	$(BROWSER) htmlcov/index.html

docs: install ## generate Sphinx HTML documentation, including API docs
	rm -f docs/alertlogic-sdk-python.rst
	rm -f docs/modules.rst
	sphinx-apidoc -o docs/ almdrlib
	$(MAKE) -C docs clean
	$(MAKE) -C docs html
	$(MAKE) -C docs redoc
	$(BROWSER) docs/_build/html/index.html

release_test: dist ## package and upload a release to test pypi
	twine upload --repository-url https://test.pypi.org/legacy/ dist/alertlogic-sdk-python-*.* dist/*

release: dist ## package and upload a release
	twine upload --skip-existing dist/alertlogic-sdk-python-*.* dist/*

dist: clean ## builds source and wheel package
	$(PYTHON) setup.py sdist

install: clean ## install the package to the active Python's site-packages
	$(PYTHON) setup.py install

uninstall:  ## uninstall the package from the active Python's site-packages
	$(PIP) uninstall alertlogic-sdk-python -y

