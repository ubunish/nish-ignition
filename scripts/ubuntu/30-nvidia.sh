#!/usr/bin/env bash
# NVIDIA driver 580-open (Isaac-Sim-compatible). 595 is too new for Isaac Sim.
set -euo pipefail
source "$(dirname "$0")/../lib.sh"
require_linux

do_check() {
  if ! lspci | grep -qi nvidia; then
    info "No NVIDIA GPU detected."
    return 0
  fi
  if has_cmd nvidia-smi && nvidia-smi >/dev/null 2>&1; then
    ok "NVIDIA driver loaded: $(nvidia-smi --query-gpu=driver_version --format=csv,noheader | head -1)"
  else
    warn "NVIDIA GPU present but no driver loaded"
  fi
  return 0
}

do_install() {
  if ! lspci | grep -qi nvidia; then
    warn "No NVIDIA GPU detected — skipping driver install."
    exit 0
  fi

  if has_cmd nvidia-smi && nvidia-smi >/dev/null 2>&1; then
    ok "NVIDIA driver already loaded: $(nvidia-smi --query-gpu=driver_version --format=csv,noheader | head -1)"
    exit 0
  fi

  log "ubuntu-drivers autoinstall (recommended driver)"
  sudo ubuntu-drivers install || warn "ubuntu-drivers install failed — falling back to explicit version"

  if ! dpkg -s nvidia-driver-580-open >/dev/null 2>&1; then
    log "apt install nvidia-driver-580-open (Isaac-Sim-compatible)"
    sudo apt-get install -y nvidia-driver-580-open
  fi

  warn "Reboot required for the NVIDIA driver to load. Run: sudo reboot"
}

do_uninstall() {
  warn "NVIDIA driver removal can break the display stack — left in place. Remove manually with 'sudo apt remove nvidia-driver-580-open' if needed."
  return 0
}

dispatch "$@"
