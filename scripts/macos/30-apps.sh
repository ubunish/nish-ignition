#!/usr/bin/env bash
# GUI apps via brew --cask.
set -euo pipefail
source "$(dirname "$0")/../lib.sh"
require_macos
has_cmd brew || { err "brew missing — run 00-homebrew.sh first"; exit 1; }

do_check() {
  local c
  for c in "${MACOS_CASKS[@]}"; do
    if brew list --cask "$c" >/dev/null 2>&1; then
      ok "$c installed"
    else
      warn "$c not installed"
    fi
  done
  return 0
}

do_install() {
  local c
  for c in "${MACOS_CASKS[@]}"; do
    if brew list --cask "$c" >/dev/null 2>&1; then
      skip "$c"
    else
      log "brew install --cask $c"
      brew install --cask "$c"
      ok "$c"
    fi
  done
}

do_uninstall() {
  local c
  for c in "${MACOS_CASKS[@]}"; do
    if brew list --cask "$c" >/dev/null 2>&1; then
      log "brew uninstall --cask $c"
      brew uninstall --cask "$c"
      ok "$c removed"
    else
      skip "$c not installed"
    fi
  done
}

dispatch "$@"
