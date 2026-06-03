#!/usr/bin/env bash
# CLI tools via Homebrew: gh, uv, python.
set -euo pipefail
source "$(dirname "$0")/../lib.sh"
require_macos
has_cmd brew || { err "brew missing — run 00-homebrew.sh first"; exit 1; }

FORMULAE=(gh uv python cloudflare-wrangler)

for f in "${FORMULAE[@]}"; do
  if brew list --formula "$f" >/dev/null 2>&1; then
    skip "$f"
  else
    log "brew install $f"
    brew install "$f"
    ok "$f"
  fi
done
