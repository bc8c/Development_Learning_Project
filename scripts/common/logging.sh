#!/usr/bin/env bash

# Prevent double inclusion
if [[ -n "${CODEX_LOGGING_SH_INCLUDED:-}" ]]; then
  return 0
fi
export CODEX_LOGGING_SH_INCLUDED=1

: "${SCRIPT_LOG_PREFIX:=bootstrap}"

BOOTSTRAP_COLOR_SUCCESS="\033[92m"   # soft green
BOOTSTRAP_COLOR_INFO="\033[94m"      # soft blue
BOOTSTRAP_COLOR_WARN="\033[93m"      # soft yellow
BOOTSTRAP_COLOR_ERROR="\033[91m"     # soft red
BOOTSTRAP_COLOR_PREFIX="\033[96m"    # soft cyan
BOOTSTRAP_COLOR_RESET="\033[0m"

print_log() {
  local color="$1"
  local message="$2"
  printf '%b[%s]%b %b%s%b\n' \
    "${BOOTSTRAP_COLOR_PREFIX}" "${SCRIPT_LOG_PREFIX}" "${BOOTSTRAP_COLOR_RESET}" \
    "${color}" "${message}" "${BOOTSTRAP_COLOR_RESET}"
}

log_success() {
  print_log "${BOOTSTRAP_COLOR_SUCCESS}" "$1"
}

log_info() {
  print_log "${BOOTSTRAP_COLOR_INFO}" "$1"
}

log_warn() {
  print_log "${BOOTSTRAP_COLOR_WARN}" "$1"
}

log_error() {
  print_log "${BOOTSTRAP_COLOR_ERROR}" "$1"
}
