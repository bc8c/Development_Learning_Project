#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

ASDF_VERSION="v0.14.0"
ASDF_DIR="${HOME}/.asdf"
ASDF_INIT_SNIPPET='. "$HOME/.asdf/asdf.sh"'
PNPM_VERSION="${PNPM_VERSION:-}"
DEFAULT_PNPM_VERSION="9.12.1"

SCRIPT_LOG_PREFIX="bootstrap"
# shellcheck disable=SC1091
source "${REPO_ROOT}/scripts/common/logging.sh"

append_shell_init() {
  local file="$1"
  if [[ -f "${file}" ]] && grep -Fq "${ASDF_INIT_SNIPPET}" "${file}"; then
    return
  fi
  log_info "${file}에 asdf 초기화 스니펫 추가"
  printf '\n%s\n' "${ASDF_INIT_SNIPPET}" >> "${file}"
}

source_asdf() {
  if [[ -f "${ASDF_DIR}/asdf.sh" ]]; then
    # shellcheck disable=SC1090
    source "${ASDF_DIR}/asdf.sh"
  fi
}

install_or_update_asdf() {
  if command -v asdf >/dev/null 2>&1; then
    log_info "asdf $(asdf --version) 이미 설치되어 있습니다."
    return
  fi

  if [[ ! -d "${ASDF_DIR}" ]]; then
    log_info "asdf가 없어 ${ASDF_DIR}에 ${ASDF_VERSION} 설치를 진행합니다."
    git clone https://github.com/asdf-vm/asdf.git "${ASDF_DIR}" --branch "${ASDF_VERSION}"
  else
    log_warn "${ASDF_DIR}가 있으나 asdf 명령을 찾지 못했습니다. 최신 상태로 업데이트합니다."
    git -C "${ASDF_DIR}" fetch --depth=1 origin "${ASDF_VERSION}"
    git -C "${ASDF_DIR}" checkout "${ASDF_VERSION}"
  fi

  append_shell_init "${HOME}/.bashrc"
  append_shell_init "${HOME}/.zshrc"

  source_asdf

  if ! command -v asdf >/dev/null 2>&1; then
    log_error "asdf 설치 후에도 명령을 찾을 수 없습니다. 셸 초기화 파일을 확인하세요."
    exit 1
  fi

  log_success "asdf $(asdf --version) 설치 완료"
}

ensure_asdf_ready() {
  source_asdf
  install_or_update_asdf
  log_info "asdf $(asdf --version) 사용"
}

get_plugin_url() {
  case "$1" in
    nodejs)
      printf '%s' "https://github.com/asdf-vm/asdf-nodejs.git"
      ;;
    java)
      printf '%s' "https://github.com/halcyon/asdf-java.git"
      ;;
    python)
      printf '%s' "https://github.com/asdf-community/asdf-python.git"
      ;;
    *)
      printf ''
      ;;
  esac
}

ensure_plugin() {
  local plugin="$1"
  local url
  url="$(get_plugin_url "${plugin}")"

  if asdf plugin list | grep -Fxq "${plugin}"; then
    log_info "플러그인 '${plugin}' 이미 추가됨"
    return
  fi

  if [[ -n "${url}" ]]; then
    log_info "플러그인 '${plugin}' 추가 (${url})"
    asdf plugin add "${plugin}" "${url}"
  else
    log_info "플러그인 '${plugin}' 추가"
    asdf plugin add "${plugin}"
  fi
}

install_required_plugins() {
  if [[ ! -f .tool-versions ]]; then
    log_warn ".tool-versions가 없어 필요한 플러그인을 추론할 수 없습니다. 기본 플러그인(nodejs, java)을 설치합니다."
    ensure_plugin "nodejs"
    ensure_plugin "java"
    return
  fi

  mapfile -t tools < <(grep -Ev '^\s*(#|$)' .tool-versions | awk '{print $1}' | sort -u)

  if [[ ${#tools[@]} -eq 0 ]]; then
    log_warn ".tool-versions에서 플러그인 식별에 실패했습니다. 기본 플러그인(nodejs, java)을 설치합니다."
    ensure_plugin "nodejs"
    ensure_plugin "java"
    return
  fi

  for plugin in "${tools[@]}"; do
    ensure_plugin "${plugin}"
  done
}

install_asdf_runtimes() {
  if [[ ! -f .tool-versions ]]; then
    log_error "프로젝트 루트에 .tool-versions가 없어 asdf 설치 대상을 알 수 없습니다."
    exit 1
  fi
  log_info ".tool-versions 기반으로 런타임 설치"
  asdf install
}

setup_asdf_environment() {
  ensure_asdf_ready
  install_required_plugins
  install_asdf_runtimes
}

resolve_pnpm_version() {
  if [[ -n "${PNPM_VERSION}" ]]; then
    return
  fi

  if command -v node >/dev/null 2>&1 && [[ -f package.json ]]; then
    local parsed
    parsed="$(node -e "try { const pkg = JSON.parse(require('fs').readFileSync('package.json','utf8')); const pm=pkg.packageManager||''; const match=/^pnpm@(.*)$/.exec(pm); if (match) process.stdout.write(match[1]); } catch (err) { process.exit(0); }")"
    if [[ -n "${parsed}" ]]; then
      PNPM_VERSION="${parsed}"
      log_info "package.json에서 pnpm ${PNPM_VERSION} 버전을 발견했습니다."
      return
    fi
  fi

  PNPM_VERSION="${DEFAULT_PNPM_VERSION}"
  log_warn "pnpm 버전을 package.json에서 찾지 못해 기본값 ${PNPM_VERSION}을 사용합니다."
}

ensure_pnpm_installed() {
  log_info "pnpm 설치 상태를 점검합니다"
  resolve_pnpm_version

  local pnpm_path=""
  local current=""
  local status=0

  if command -v pnpm >/dev/null 2>&1; then
    pnpm_path="$(command -v pnpm)"
    set +e
    "${pnpm_path}" --version >/dev/null 2>&1
    status=$?
    set -e
    if [[ ${status} -eq 0 ]]; then
      current="$("${pnpm_path}" --version)"
      if [[ "${current}" == "${PNPM_VERSION}" ]]; then
        log_info "pnpm ${current} 이미 설치되어 있습니다."
        return
      fi
      log_warn "pnpm ${current} 감지됨. ${PNPM_VERSION}으로 재설치합니다."
    else
      log_warn "pnpm 명령이 있으나 버전 확인에 실패했습니다. 재설치를 진행합니다."
    fi
  fi

  if ! command -v npm >/dev/null 2>&1; then
    log_error "npm을 찾을 수 없어 pnpm을 설치할 수 없습니다. Node/npm 환경을 확인하세요."
    exit 1
  fi

  local npm_prefix
  npm_prefix="$(npm prefix -g)"
  local npm_bin="${npm_prefix}/bin"
  log_info "기존 pnpm 링크를 정리합니다 (${npm_bin}/pnpm, ${npm_bin}/pnpx)"
  rm -f "${npm_bin}/pnpm" "${npm_bin}/pnpx"

  if command -v asdf >/dev/null 2>&1; then
    log_info "기존 asdf pnpm 쉼을 정리합니다"
    rm -f "${HOME}/.asdf/shims/pnpm" "${HOME}/.asdf/shims/pnpx"
  fi

  log_info "npm을 통해 pnpm@${PNPM_VERSION} 전역 설치"
  if [[ -n "${CI:-}" || -n "${GITHUB_ACTIONS:-}" ]]; then
    ASDF_SKIP_RESHIM=1 npm install -g "pnpm@${PNPM_VERSION}"
  else
    npm install -g "pnpm@${PNPM_VERSION}"
  fi

  local npm_global_bin
  npm_global_bin="$(npm bin -g)"
  if [[ -n "${npm_global_bin}" ]]; then
    export PATH="${npm_global_bin}:$PATH"
    if [[ -n "${GITHUB_ENV:-}" ]]; then
      echo "PATH=${npm_global_bin}:$PATH" >> "${GITHUB_ENV}"
    fi
    log_info "npm 글로벌 bin 경로(${npm_global_bin})를 PATH에 추가했습니다."
  fi

  if command -v asdf >/dev/null 2>&1; then
    if [[ -n "${CI:-}" || -n "${GITHUB_ACTIONS:-}" ]]; then
      log_info "CI 환경에서는 asdf reshim 단계를 건너뜁니다"
    else
      log_info "asdf shim을 갱신합니다"
      asdf reshim nodejs >/dev/null 2>&1 || true
    fi
  fi

  log_success "pnpm $(pnpm --version) 설치 완료"
}

ensure_pre_commit_ready() {
  ensure_pre_commit_installed
  install_pre_commit_hook
}

ensure_pre_commit_installed() {
  if command -v pre-commit >/dev/null 2>&1; then
    log_info "$(pre-commit --version) 이미 설치되어 있습니다."
    return
  fi

  local python_cmd="python3"
  local pip_cmd="python3 -m pip"

  if command -v asdf >/dev/null 2>&1 && asdf which python >/dev/null 2>&1; then
    python_cmd="asdf exec python"
    pip_cmd="asdf exec pip"
  elif ! command -v python3 >/dev/null 2>&1; then
    log_warn "python3를 찾지 못해 pre-commit 설치를 건너뜁니다."
    return
  fi

  if ! ${pip_cmd} --version >/dev/null 2>&1; then
    log_warn "pip을 사용할 수 없어 pre-commit 설치를 건너뜁니다."
    return
  fi

  log_info "pre-commit 패키지를 설치합니다."
  local install_cmd
  if [[ "${pip_cmd}" == "asdf exec pip" ]]; then
    install_cmd=(asdf exec pip install --upgrade pre-commit)
  else
    install_cmd=(${python_cmd} -m pip install --user --upgrade pre-commit)
  fi

  if ! "${install_cmd[@]}" >/dev/null 2>&1; then
    log_warn "pre-commit 설치에 실패했습니다. 수동으로 설치 후 다시 실행하세요."
    return
  fi

  if command -v asdf >/dev/null 2>&1; then
    asdf reshim python >/dev/null 2>&1 || true
  fi

  if command -v pre-commit >/dev/null 2>&1; then
    log_success "$(pre-commit --version) 설치 완료"
  else
    log_success "pre-commit 설치 완료"
  fi
}

install_pre_commit_hook() {
  local installer="${REPO_ROOT}/scripts/pre-commit/install.sh"
  if [[ ! -x "${installer}" ]]; then
    log_warn "${installer} 파일이 없거나 실행 불가하여 훅 설치를 건너뜁니다."
    return
  fi

  PRE_COMMIT_HOME="${REPO_ROOT}/.pre-commit-cache" \
    "${installer}" >/dev/null && \
    log_success "pre-commit 훅 설치 완료" || \
    log_warn "pre-commit 훅 설치에 실패했습니다."
}

init_env() {
  setup_asdf_environment
  ensure_pnpm_installed
  ensure_pre_commit_ready
  log_success "환경 부트스트랩 완료"
}

init_env
