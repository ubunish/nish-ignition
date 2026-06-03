#!/usr/bin/env bash
# Enable SSH server so the workstation can be reached from the MacBook.
set -euo pipefail
source "$(dirname "$0")/../lib.sh"
require_linux

do_check() {
  dpkg -s openssh-server >/dev/null 2>&1 && ok "openssh-server installed" || warn "openssh-server missing"
  if systemctl is-enabled ssh >/dev/null 2>&1; then
    ok "ssh service enabled"
  else
    warn "ssh service not enabled"
  fi
  return 0
}

do_install() {
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
}

do_uninstall() {
  if systemctl is-enabled ssh >/dev/null 2>&1; then
    log "Disabling + stopping ssh"
    sudo systemctl disable --now ssh
    ok "ssh disabled"
  else
    skip "ssh service not enabled"
  fi
  warn "openssh-server package left in place — remove manually with 'sudo apt remove openssh-server' if unwanted."
  return 0
}

dispatch "$@"
