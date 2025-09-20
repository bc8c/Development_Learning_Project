#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${REPO_ROOT}"

# ensure asdf commands are available when running as standalone script
if [ -s "$HOME/.asdf/asdf.sh" ]; then
  # shellcheck disable=SC1090
  . "$HOME/.asdf/asdf.sh"
fi

PYTHON_CMD="python3"
if command -v asdf >/dev/null 2>&1 && asdf which python >/dev/null 2>&1; then
  PYTHON_CMD="asdf exec python"
elif ! command -v python3 >/dev/null 2>&1; then
  echo "python3 명령을 찾을 수 없습니다. pre-commit 훅 설치 전에 Python 환경을 준비하세요." >&2
  exit 1
fi

if ! ${PYTHON_CMD} -m pre_commit --version >/dev/null 2>&1; then
  echo "pre-commit 패키지가 설치되어 있지 않습니다. 먼저 설치하세요." >&2
  exit 1
fi

export PRE_COMMIT_HOME="${REPO_ROOT}/.pre-commit-cache"
mkdir -p "${PRE_COMMIT_HOME}"

env PRE_COMMIT_HOME="${PRE_COMMIT_HOME}" ${PYTHON_CMD} -m pre_commit install --hook-type pre-commit

HOOK_PATH="${REPO_ROOT}/.git/hooks/pre-commit"
if [[ -f "${HOOK_PATH}" ]]; then
  python3 - "$HOOK_PATH" "${PRE_COMMIT_HOME}" <<'PY'
import sys
from pathlib import Path

path_str, cache = sys.argv[1:3]
path = Path(path_str)
text = path.read_text()
lines = text.splitlines()
if any(line.startswith('export PRE_COMMIT_HOME=') for line in lines):
    sys.exit(0)
for idx, line in enumerate(lines):
    if line.startswith('# start templated'):
        lines.insert(idx, f'export PRE_COMMIT_HOME="{cache}"')
        break
else:
    lines.insert(1, f'export PRE_COMMIT_HOME="{cache}"')

path.write_text('\n'.join(lines) + '\n')
PY
fi
