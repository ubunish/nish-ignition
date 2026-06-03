#!/usr/bin/env bash
# nish-ignition entrypoint
# Detects OS and runs the manifest's steps in order.
# Each step is idempotent and may be run standalone from scripts/<os>/.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib.sh
source "$HERE/scripts/lib.sh"

OS="$(uname -s)"
case "$OS" in
  Darwin) STEPS_DIR="$HERE/scripts/macos";  PLATFORM="macOS";  STEPS=("${MACOS_STEPS[@]}")  ;;
  Linux)  STEPS_DIR="$HERE/scripts/ubuntu"; PLATFORM="Ubuntu"; STEPS=("${UBUNTU_STEPS[@]}") ;;
  *) err "Unsupported OS: $OS"; exit 1 ;;
esac

MODE="install"
LIST=0
# DISABLED / ONLY are declared in lib.sh; the flag parser fills them.

usage() {
  cat <<EOF
nish-ignition — robotics workstation installer ($PLATFORM)

Usage: ./setup.sh [options]

Options:
  --only  a,b,c   Run only these step ids (skip everything else)
  --skip  a,b,c   Run every step except these ids
  --uninstall     Reverse installs where reversible (runs steps in reverse)
  --list          List every step id with its file and default state, then exit
  -h, --help      Show this help

Step ids come from scripts/manifest.sh. Comma-separate or repeat a flag.
Set NONINTERACTIVE=1 to skip all prompts.
EOF
}

# Split a comma-separated value into the named array (appending).
_collect() {
  local arr="$1" raw="$2" part
  local IFS=','
  for part in $raw; do
    [[ -n "$part" ]] && eval "$arr+=(\"\$part\")"
  done
}

while (($#)); do
  case "$1" in
    --only)      _collect ONLY "${2:-}";     shift 2 ;;
    --skip)      _collect DISABLED "${2:-}"; shift 2 ;;
    --uninstall) MODE="uninstall";           shift ;;
    --list)      LIST=1;                      shift ;;
    -h|--help)   usage; exit 0 ;;
    *) err "unknown option: $1"; usage; exit 1 ;;
  esac
done

if ((LIST)); then
  log "nish-ignition steps — $PLATFORM"
  printf '    %-16s %-22s %s\n' "ID" "FILE" "DEFAULT"
  for entry in "${STEPS[@]}"; do
    IFS='|' read -r id file default <<<"$entry"
    printf '    %-16s %-22s %s\n' "$id" "$file" "$default"
  done
  exit 0
fi

# Uninstall reverses the install order so dependents come down before deps.
if [[ "$MODE" == "uninstall" ]]; then
  reversed=()
  for ((i = ${#STEPS[@]} - 1; i >= 0; i--)); do
    reversed+=("${STEPS[$i]}")
  done
  STEPS=("${reversed[@]}")
fi

log "nish-ignition — $PLATFORM [$MODE]"
info "Step dir: $STEPS_DIR"
info "Set NONINTERACTIVE=1 to skip all prompts (manual steps will be flagged, not run)."
echo

for entry in "${STEPS[@]}"; do
  IFS='|' read -r id file default <<<"$entry"
  if is_enabled "$id" "$default"; then
    log "$id ($file) [$MODE]"
    bash "$STEPS_DIR/$file" "$MODE"
    echo
  else
    skip "$id"
  fi
done

log "Done."
