#!/usr/bin/env bash
# Install vcstool and clone Nish's repos (repos.yaml) into ~/code.
set -euo pipefail
source "$(dirname "$0")/../lib.sh"
require_linux

do_check() {
  if has_cmd vcs; then
    ok "vcstool installed"
  else
    warn "vcstool not installed"
  fi
  if [[ -d "$CODE_DIR" ]]; then
    ok "code dir exists: $CODE_DIR ($(find "$CODE_DIR" -maxdepth 1 -type d | tail -n +2 | wc -l | tr -d ' ') repos)"
  else
    warn "code dir missing: $CODE_DIR"
  fi
  return 0
}

do_install() {
  if has_cmd vcs; then
    ok "vcstool already installed"
  else
    log "apt install python3-vcstool"
    sudo apt-get install -y python3-vcstool
    ok "vcstool installed"
  fi
  import_repos
}

do_uninstall() {
  warn "Cloned repos in $CODE_DIR are left in place (they may hold local work)."
  info "Remove manually if you are sure: rm -rf $CODE_DIR"
  return 0
}

dispatch "$@"
