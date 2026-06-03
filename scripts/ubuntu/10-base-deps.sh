#!/usr/bin/env bash
# Base CLI deps.
set -euo pipefail
source "$(dirname "$0")/../lib.sh"
require_linux

do_check() {
  local p
  for p in "${UBUNTU_APT[@]}"; do
    if dpkg -s "$p" >/dev/null 2>&1; then
      ok "$p installed"
    else
      warn "$p missing"
    fi
  done
  return 0
}

do_install() {
  MISSING=()
  for p in "${UBUNTU_APT[@]}"; do
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
}

do_uninstall() {
  warn "Base deps (curl, git, etc.) underpin the rest of the system — left in place."
  return 0
}

dispatch "$@"
