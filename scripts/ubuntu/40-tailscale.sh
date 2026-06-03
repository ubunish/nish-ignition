#!/usr/bin/env bash
# Tailscale.
set -euo pipefail
source "$(dirname "$0")/../lib.sh"
require_linux

do_check() {
  if has_cmd tailscale; then
    ok "Tailscale installed ($(tailscale version | head -1))"
  else
    warn "Tailscale missing"
  fi
  return 0
}

do_install() {
  if has_cmd tailscale; then
    ok "Tailscale already installed ($(tailscale version | head -1))"
  else
    log "Installing Tailscale"
    curl -fsSL https://tailscale.com/install.sh | sh
    ok "Tailscale installed"
  fi

  info "Authenticate with: sudo tailscale up"
}

do_uninstall() {
  if has_cmd tailscale; then
    log "apt remove tailscale"
    sudo apt-get remove -y tailscale
    ok "Tailscale removed"
  else
    skip "Tailscale not installed"
  fi
}

dispatch "$@"
