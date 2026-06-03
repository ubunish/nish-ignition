#!/usr/bin/env bash
# GUI apps: Chrome, Slack, VS Code, Foxglove Studio.
set -euo pipefail
source "$(dirname "$0")/../lib.sh"
require_linux

do_check() {
  dpkg -s google-chrome-stable >/dev/null 2>&1 && ok "google-chrome-stable installed" || warn "google-chrome-stable missing"
  snap list slack >/dev/null 2>&1 && ok "slack installed" || warn "slack missing"
  snap list code >/dev/null 2>&1 && ok "code installed" || warn "code missing"
  dpkg -s foxglove-studio >/dev/null 2>&1 && ok "foxglove-studio installed" || warn "foxglove-studio missing"
  return 0
}

do_install() {
  install_deb() {
    local name="$1" url="$2"
    if dpkg -s "$name" >/dev/null 2>&1; then
      skip "$name"
      return
    fi
    local tmp
    tmp="$(mktemp --suffix=.deb)"
    log "Downloading $name"
    curl -fsSL "$url" -o "$tmp"
    sudo apt-get install -y "$tmp"
    rm -f "$tmp"
    ok "$name installed"
  }

  # Google Chrome
  install_deb google-chrome-stable \
    https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

  # Slack (Snap is the canonical Ubuntu install path)
  if snap list slack >/dev/null 2>&1; then
    skip "slack"
  else
    log "snap install slack"
    sudo snap install slack
    ok "slack installed"
  fi

  # VS Code (snap, classic)
  if snap list code >/dev/null 2>&1; then
    skip "code"
  else
    log "snap install code --classic"
    sudo snap install code --classic
    ok "code installed"
  fi

  # Foxglove Studio (.deb from official downloads)
  if dpkg -s foxglove-studio >/dev/null 2>&1; then
    skip "foxglove-studio"
  else
    warn "Foxglove publishes versioned .deb files — install manually from https://foxglove.dev/download"
    pause "Download and install Foxglove Studio when ready."
  fi
}

do_uninstall() {
  if dpkg -s google-chrome-stable >/dev/null 2>&1; then
    log "apt remove google-chrome-stable"
    sudo apt-get remove -y google-chrome-stable
    ok "google-chrome-stable removed"
  else
    skip "google-chrome-stable not installed"
  fi
  if snap list slack >/dev/null 2>&1; then
    log "snap remove slack"
    sudo snap remove slack
    ok "slack removed"
  else
    skip "slack not installed"
  fi
  if snap list code >/dev/null 2>&1; then
    log "snap remove code"
    sudo snap remove code
    ok "code removed"
  else
    skip "code not installed"
  fi
  if dpkg -s foxglove-studio >/dev/null 2>&1; then
    log "apt remove foxglove-studio"
    sudo apt-get remove -y foxglove-studio
    ok "foxglove-studio removed"
  else
    skip "foxglove-studio not installed"
  fi
}

dispatch "$@"
