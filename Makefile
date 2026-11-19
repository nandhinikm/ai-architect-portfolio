.PHONY: setup check
setup:
	pip install pre-commit
	pre-commit install
check:
	pre-commit run --all-files
