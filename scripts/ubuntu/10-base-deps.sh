#!/usr/bin/env bash
# Base CLI deps.
set -euo pipefail
source "$(dirname "$0")/../lib.sh"
require_linux

PACKAGES=(curl git openssh-server ca-certificates gnupg lsb-release software-properties-common)

MISSING=()
for p in "${PACKAGES[@]}"; do
  if dpkg -s "$p" >/dev/null 2>&1; then
    skip "$p"
  else
    MISSING+=("$p")
  fi
done

if ((${#MISSING[@]})); then
  log "apt install ${MISSING[*]}"
  sudo apt-get install -y "${MISSING[@]}"
  ok "base deps installed"
fi
