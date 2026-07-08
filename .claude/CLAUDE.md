# Global Development Preferences

## Workflow
- When a request is ambiguous, always ask clarifying questions before proceeding
- Before making any code changes, outline your plan and wait for explicit approval
- Do not make git commits — I prefer to commit manually

## Safety Guards (Do Not Modify Without Permission)

The following files implement security guardrails and must never be edited,
deleted, or overwritten without my explicit instruction in that session:

- `~/.claude/hooks/guard.py`
- `~/.claude/settings.json`

Do not suggest modifications to these files. Do not work around them if they
block a command — instead, stop and tell me what was blocked and why.

## Python Environment
- Always use `uv` for environment and package management — never invoke `python` or `pip` directly
- Use `uv run` to execute scripts, `uv add` to add dependencies, `uv sync` to install
- Dev dependencies (ty, ruff, pytest, etc.) go in `pyproject.toml`, installed via `uv add --dev`
- Exception: if a tool or context genuinely requires a bare `python` invocation, use judgment and note why

## Linting & Formatting
- Use `ruff` for both linting and formatting (replaces flake8, black, isort)

## Type Checking
- Use `ty` for type checking (not mypy or pyright)
- `ty` should be listed as a dev dependency in `pyproject.toml`

## Pre-commit Hooks
- Use `prek` for pre-commit hook management (not pre-commit)

## Testing
- Prefer `pytest` over `unittest`
- Use pytest conventions: `conftest.py`, fixtures, `pytest.ini` or `pyproject.toml` config

## Metaflow
- Always use Outerbounds' Metaflow distribution (not open-source metaflow)
- Prefer `metaflow.S3` over `boto3` for S3 access
- Prefer `metaflow.Snowflake` over snowflake-connector-python with RSA/password auth
- Flows should read as a DAG only — business logic and helper functions belong in separate modules, imported into the flow
- Use `@pypi` decorator for step-level dependencies (not `@conda`)
- Where possible, source dependencies from `pyproject.toml` rather than hardcoding them in decorators

## CI/CD
- Implement CI with GitHub Actions (not CircleCI, Jenkins, etc.)

## Git
- Branch naming: use `feat/`, `feature/`, or `fix/` prefixes
- Commits should be atomic — one logical change per commit
- Do not make commits on my behalf; I commit manually
