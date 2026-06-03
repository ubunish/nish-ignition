#!/usr/bin/env bash
# Interactive sign-ins.
set -euo pipefail
source "$(dirname "$0")/../lib.sh"

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
