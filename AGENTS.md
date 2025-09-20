# Repository Guidelines

## IMPORTANTS
- Always answer in Korean
- 모든 git 관련 명령은 사용자의 명시적 확인 후에만 실행할 것

## Project Structure & Module Organization
- Keep production code in `src/` with domain-focused packages (for example `src/agents/dispatcher.py`).
- Mirror that layout in `tests/` (`tests/agents/test_dispatcher.py`) and store reusable fixtures in `tests/fixtures/`.
- Place developer docs inside `docs/` and diagram assets in `docs/architecture/`.
- Park helper automation in `scripts/`; make files executable and prefer Python entry points.
- 학습/연구 관련 문서는 `docs/learning_notes/`에 저장하고, 작성 전 `docs/learning_notes/learning_notes_guidelines.md`를 반드시 확인합니다.

## Build, Test, and Development Commands
- `python -m venv .venv && source .venv/bin/activate`: create and enter the project virtualenv.
- `pip install -r requirements.txt`: sync dependencies; regenerate the lock when adding packages.
- `pytest`: run the full automated suite; add `-k <pattern>` for focused runs.
- `ruff check src tests` and `black src tests`: lint and format before committing.

## Coding Style & Naming Conventions
- Target Python 3.11, 4-space indentation, and comprehensive type hints.
- Modules are lower_snake_case, classes PascalCase, functions/variables snake_case, constants UPPER_SNAKE_CASE.
- Prefer small, single-purpose functions (<50 lines) and replace magic numbers with named constants.
- Use f-strings for logging and wrap external I/O with structured exception handling.

## Testing Guidelines
- Write pytest-based unit tests that mirror the `src/` namespace; name files `test_<module>.py`.
- Maintain ≥90% coverage (`pytest --cov=src --cov-report=term-missing`) and include regression tests for bug fixes.
- Mark long-running tests with `@pytest.mark.slow`; default CI runs the short suite.

## Commit & Pull Request Guidelines
- Follow Conventional Commits (`feat:`, `fix:`, `docs:`, etc.); keep scopes concise (`feat: scheduler`).
- Each commit should be atomic and include matching updates to tests/docs when behavior changes.
- Pull requests must summarize intent, link issues, and attach test evidence (command output or screenshots).
- Require at least one maintainer review and a green CI run before merging.

## Security & Configuration Tips
- Store sensitive data in `.env.local` (git-ignored) and load values via `os.getenv`.
- Document environment variables and service credentials in `docs/configuration.md`.
- Validate all external input at module boundaries and strip secrets from logs before pushing.
