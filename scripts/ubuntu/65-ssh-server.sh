#!/usr/bin/env bash
# Enable SSH server so the workstation can be reached from the MacBook.
set -euo pipefail
source "$(dirname "$0")/../lib.sh"
require_linux

if ! dpkg -s openssh-server >/dev/null 2>&1; then
  log "Installing openssh-server"
  sudo apt-get install -y openssh-server
fi

if systemctl is-enabled ssh >/dev/null 2>&1; then
  ok "ssh service already enabled"
else
  log "Enabling + starting ssh"
  sudo systemctl enable --now ssh
  ok "ssh enabled"
fi

info "From your MacBook: ssh-copy-id $USER@$(hostname)"
