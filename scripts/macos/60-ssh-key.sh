#!/usr/bin/env bash
# Generate an ed25519 SSH key tied to the user's Ubundi email.
set -euo pipefail
source "$(dirname "$0")/../lib.sh"

KEY="$HOME/.ssh/id_ed25519"

do_check() {
  if [[ -f "$KEY" ]]; then
    ok "SSH key exists at $KEY"
  else
    warn "SSH key not found at $KEY"
  fi
  return 0
}

do_install() {
  if [[ -f "$KEY" ]]; then
    ok "SSH key already exists at $KEY"
    return 0
  fi

  email="${UBUNDI_EMAIL:-}"
  if [[ -z "$email" ]]; then
    if [[ "${NONINTERACTIVE:-0}" == "1" ]]; then
      warn "No UBUNDI_EMAIL set — skipping ssh-keygen. Run later: ssh-keygen -t ed25519 -C <you>@ubundi.co.za"
      return 0
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
}

do_uninstall() {
  # SSH keys are irreplaceable credentials — never auto-delete them.
  warn "SSH key left in place — delete $KEY and $KEY.pub manually if you are sure"
}

dispatch "$@"
