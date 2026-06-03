#!/usr/bin/env bash
# GUI apps via brew --cask.
set -euo pipefail
source "$(dirname "$0")/../lib.sh"
require_macos
has_cmd brew || { err "brew missing — run 00-homebrew.sh first"; exit 1; }

CASKS=(
  slack
  claude
  visual-studio-code
  google-drive
  foxglove-studio
  orbstack
)

for c in "${CASKS[@]}"; do
  if brew list --cask "$c" >/dev/null 2>&1; then
    skip "$c"
  else
    log "brew install --cask $c"
    brew install --cask "$c"
    ok "$c"
  fi
done
