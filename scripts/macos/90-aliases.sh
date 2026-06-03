#!/usr/bin/env bash
# Shell aliases for the robotics venvs.
set -euo pipefail
source "$(dirname "$0")/../lib.sh"

ZSHRC="$HOME/.zshrc"
touch "$ZSHRC"

add_alias() {
  local line="$1"
  if grep -Fxq "$line" "$ZSHRC"; then
    skip "alias already in .zshrc: $line"
  else
    echo "$line" >> "$ZSHRC"
    ok "added: $line"
  fi
}

add_alias 'alias mj="source ~/.venvs/mujoco/bin/activate"'
add_alias 'alias lr="source ~/.venvs/lerobot/bin/activate"'

info "Reload your shell or 'source ~/.zshrc' to pick up the aliases."
