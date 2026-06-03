#!/usr/bin/env bash
# OPT-IN: grant the current user passwordless sudo. Security-sensitive — prompts before applying.
set -euo pipefail
source "$(dirname "$0")/../lib.sh"
require_linux

SUDOERS=/etc/sudoers.d/nopasswd_users

if sudo test -f "$SUDOERS" && sudo grep -q "^$USER ALL=(ALL) NOPASSWD: ALL" "$SUDOERS"; then
  ok "$USER already has NOPASSWD sudo"
  exit 0
fi

warn "This grants $USER passwordless sudo on the entire system."
warn "Anyone who compromises this account gains full root with no password challenge."
if ! confirm "Apply NOPASSWD sudo for $USER?"; then
  skip "NOPASSWD sudo declined — staying with password-required sudo."
  exit 0
fi

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
echo "$USER ALL=(ALL) NOPASSWD: ALL" > "$tmp"

if sudo visudo -cf "$tmp" >/dev/null; then
  sudo install -m 0440 "$tmp" "$SUDOERS"
  ok "$USER granted NOPASSWD sudo via $SUDOERS"
else
  err "visudo syntax check failed — aborting"
  exit 1
fi
