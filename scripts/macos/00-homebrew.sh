#!/usr/bin/env bash
# Install Homebrew (also pulls Xcode Command Line Tools as a dependency).
set -euo pipefail
source "$(dirname "$0")/../lib.sh"
require_macos

do_check() {
  if has_cmd brew; then
    ok "Homebrew already installed ($(brew --version | head -1))"
  else
    warn "Homebrew not installed"
  fi
  return 0
}

do_install() {
  if has_cmd brew; then
    ok "Homebrew already installed ($(brew --version | head -1))"
    return 0
  fi

  log "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add brew to PATH for Apple Silicon (Intel Macs already have /usr/local/bin in PATH).
  if [[ -x /opt/homebrew/bin/brew ]] && ! grep -q 'brew shellenv' "$HOME/.zprofile" 2>/dev/null; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi

  ok "Homebrew installed"
}

do_uninstall() {
  # Removing Homebrew is destructive — it owns every formula and cask. Leave it.
  warn "Homebrew left in place — uninstall manually if needed (see Homebrew's uninstall.sh)"
}

dispatch "$@"
