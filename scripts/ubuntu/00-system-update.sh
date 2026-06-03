#!/usr/bin/env bash
# Update apt + upgrade. No reboot (left for the operator if kernel changed).
set -euo pipefail
source "$(dirname "$0")/../lib.sh"
require_linux

do_check() {
  info "System update is a one-shot apt action — nothing to report. Run 'apt list --upgradable' to see pending upgrades."
  return 0
}

do_install() {
  log "apt update && apt upgrade"
  sudo apt-get update
  sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
  ok "System updated"

  if [[ -f /var/run/reboot-required ]]; then
    warn "Reboot required — run 'sudo reboot' after the script finishes."
  fi
}

do_uninstall() {
  warn "System upgrade is not reversible — packages left in place."
  return 0
}

dispatch "$@"
