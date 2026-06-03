#!/usr/bin/env bash
# nish-ignition entrypoint
# Detects OS and runs the appropriate scripts in order.
# Each step is idempotent and may be run standalone from scripts/<os>/.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib.sh
source "$HERE/scripts/lib.sh"

OS="$(uname -s)"
case "$OS" in
  Darwin) STEPS_DIR="$HERE/scripts/macos"; PLATFORM="macOS"  ;;
  Linux)  STEPS_DIR="$HERE/scripts/ubuntu"; PLATFORM="Ubuntu" ;;
  *) err "Unsupported OS: $OS"; exit 1 ;;
esac

log "nish-ignition — $PLATFORM"
info "Step dir: $STEPS_DIR"
info "Set NONINTERACTIVE=1 to skip all prompts (manual steps will be flagged, not run)."
echo

mapfile -t STEPS < <(find "$STEPS_DIR" -maxdepth 1 -name '[0-9]*.sh' | sort)

for step in "${STEPS[@]}"; do
  name="$(basename "$step")"
  log "Running $name"
  bash "$step"
  echo
done

log "Done."
