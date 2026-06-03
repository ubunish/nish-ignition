#!/usr/bin/env bash
# Update apt + upgrade. No reboot (left for the operator if kernel changed).
set -euo pipefail
source "$(dirname "$0")/../lib.sh"
require_linux

log "apt update && apt upgrade"
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
ok "System updated"

if [[ -f /var/run/reboot-required ]]; then
  warn "Reboot required — run 'sudo reboot' after the script finishes."
fi
