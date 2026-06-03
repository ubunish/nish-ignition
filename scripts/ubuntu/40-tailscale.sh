#!/usr/bin/env bash
# Tailscale.
set -euo pipefail
source "$(dirname "$0")/../lib.sh"
require_linux

if has_cmd tailscale; then
  ok "Tailscale already installed ($(tailscale version | head -1))"
else
  log "Installing Tailscale"
  curl -fsSL https://tailscale.com/install.sh | sh
  ok "Tailscale installed"
fi

info "Authenticate with: sudo tailscale up"
