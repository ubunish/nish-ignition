#!/usr/bin/env bash
# Interactive sign-ins.
set -euo pipefail
source "$(dirname "$0")/../lib.sh"

do_check() {
  if has_cmd gh && gh auth status >/dev/null 2>&1; then
    ok "gh authenticated as $(gh api user --jq .login)"
  else
    warn "gh not authenticated"
  fi
  return 0
}

do_install() {
  # GitHub
  if has_cmd gh && gh auth status >/dev/null 2>&1; then
    ok "gh already authenticated as $(gh api user --jq .login)"
  else
    if [[ "${NONINTERACTIVE:-0}" == "1" ]]; then
      warn "Skipping gh auth login (NONINTERACTIVE). Run later: gh auth login"
    else
      log "gh auth login"
      gh auth login
    fi
  fi

  # Claude Code
  info "Sign into Claude Code manually with: claude /login"
  pause "Open a terminal and run 'claude /login' if you haven't yet."
}

do_uninstall() {
  # Signing out is a manual, per-service decision (gh auth logout, claude /logout).
  warn "Sign-ins left in place — log out manually if needed (gh auth logout)"
}

dispatch "$@"
