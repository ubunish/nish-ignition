#!/usr/bin/env bash
# CLI tools via Homebrew: gh, uv, python, node.
set -euo pipefail
source "$(dirname "$0")/../lib.sh"
require_macos
has_cmd brew || { err "brew missing — run 00-homebrew.sh first"; exit 1; }

do_check() {
  local f
  for f in "${MACOS_FORMULAE[@]}"; do
    if brew list --formula "$f" >/dev/null 2>&1; then
      ok "$f installed"
    else
      warn "$f not installed"
    fi
  done
  return 0
}

do_install() {
  local f
  for f in "${MACOS_FORMULAE[@]}"; do
    if brew list --formula "$f" >/dev/null 2>&1; then
      skip "$f"
    else
      log "brew install $f"
      brew install "$f"
      ok "$f"
    fi
  done
}

do_uninstall() {
  local f
  for f in "${MACOS_FORMULAE[@]}"; do
    if brew list --formula "$f" >/dev/null 2>&1; then
      log "brew uninstall $f"
      brew uninstall "$f"
      ok "$f removed"
    else
      skip "$f not installed"
    fi
  done
}

dispatch "$@"
