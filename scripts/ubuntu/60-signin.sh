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
  info "Claude Code sign-in state is not machine-checkable — verify with 'claude /login'."
  return 0
}

do_install() {
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

  info "Sign into Claude Code manually with: claude /login"
  pause "Run 'claude /login' if you haven't yet."
}

do_uninstall() {
  if has_cmd gh && gh auth status >/dev/null 2>&1; then
    log "gh auth logout"
    gh auth logout || true
    ok "gh logged out"
  else
    skip "gh not authenticated"
  fi
  info "Sign out of Claude Code manually with: claude /logout"
  return 0
}

dispatch "$@"
