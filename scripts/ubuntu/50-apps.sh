#!/usr/bin/env bash
# GUI apps: Chrome, Slack, VS Code, Foxglove Studio.
set -euo pipefail
source "$(dirname "$0")/../lib.sh"
require_linux

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
