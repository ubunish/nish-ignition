#!/usr/bin/env bash
# Shared helpers for setup scripts. Source, don't execute.

set -euo pipefail

BOLD=$'\e[1m'; DIM=$'\e[2m'; RED=$'\e[31m'; GREEN=$'\e[32m'; YELLOW=$'\e[33m'; BLUE=$'\e[34m'; RESET=$'\e[0m'

log()    { printf '%s\n' "${BLUE}==>${RESET} ${BOLD}$*${RESET}"; }
info()   { printf '%s\n' "    $*"; }
ok()     { printf '%s\n' "${GREEN}    ✓${RESET} $*"; }
skip()   { printf '%s\n' "${DIM}    ↷ $* (skip)${RESET}"; }
warn()   { printf '%s\n' "${YELLOW}    !${RESET} $*"; }
err()    { printf '%s\n' "${RED}    ✗${RESET} $*" >&2; }

has_cmd() { command -v "$1" >/dev/null 2>&1; }

# pause "message" — print and wait for Enter (skipped under NONINTERACTIVE=1)
pause() {
  if [[ "${NONINTERACTIVE:-0}" == "1" ]]; then
    warn "$* (NONINTERACTIVE — skipping pause)"
    return
  fi
  printf '%s\n' "${YELLOW}    →${RESET} $*"
  read -r -p "    Press Enter to continue… " _
}

# confirm "question" — y/N prompt; returns 0 on yes (auto-no under NONINTERACTIVE=1)
confirm() {
  if [[ "${NONINTERACTIVE:-0}" == "1" ]]; then
    warn "$* — auto-declined (NONINTERACTIVE)"
    return 1
  fi
  local reply
  read -r -p "    ${YELLOW}?${RESET} $* [y/N] " reply
  [[ "$reply" =~ ^[Yy]$ ]]
}

require_macos() { [[ "$(uname -s)" == "Darwin" ]] || { err "macOS only"; exit 1; }; }
require_linux() { [[ "$(uname -s)" == "Linux"  ]] || { err "Linux only";  exit 1; }; }
