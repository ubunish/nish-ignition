#!/usr/bin/env bash
# Generate an ed25519 SSH key tied to the user's Ubundi email.
set -euo pipefail
source "$(dirname "$0")/../lib.sh"

KEY="$HOME/.ssh/id_ed25519"

if [[ -f "$KEY" ]]; then
  ok "SSH key already exists at $KEY"
  exit 0
fi

email="${UBUNDI_EMAIL:-}"
if [[ -z "$email" ]]; then
  if [[ "${NONINTERACTIVE:-0}" == "1" ]]; then
    warn "No UBUNDI_EMAIL set — skipping ssh-keygen. Run later: ssh-keygen -t ed25519 -C <you>@ubundi.co.za"
    exit 0
  fi
  read -r -p "    Ubundi email for the SSH key (e.g. nish@ubundi.co.za): " email
fi

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
ssh-keygen -t ed25519 -C "$email" -f "$KEY" -N ""
ok "Wrote $KEY"

info "Public key:"
cat "$KEY.pub"
if has_cmd gh && gh auth status >/dev/null 2>&1; then
  if confirm "Upload this key to GitHub via gh?"; then
    gh ssh-key add "$KEY.pub" --title "$(hostname -s) ($(date +%Y-%m-%d))"
    ok "Uploaded to GitHub"
  fi
fi
