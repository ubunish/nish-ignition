#!/usr/bin/env bash
# Robotics Python env via uv: mujoco in ~/.venvs/mujoco.
set -euo pipefail
source "$(dirname "$0")/../lib.sh"
has_cmd uv || { err "uv missing — run 20-cli-tools.sh first"; exit 1; }

do_check() {
  local path="$HOME/.venvs/mujoco"
  [[ -d "$path" ]] && ok "mujoco venv at $path" || warn "mujoco venv missing"
  return 0
}

do_install() {
  make_env() {
    local name="$1" pkg="$2" path="$HOME/.venvs/$name"
    if [[ -d "$path" ]]; then
      skip "$name venv exists at $path"
      return
    fi
    log "Creating $name venv at $path"
    uv venv "$path" --python 3.11
    uv pip install --python "$path/bin/python" "$pkg"
    ok "$name ready (activate: source $path/bin/activate)"
  }

  make_env mujoco mujoco
}

do_uninstall() {
  local path="$HOME/.venvs/mujoco"
  if [[ -d "$path" ]]; then
    if confirm "Remove mujoco venv at $path?"; then
      rm -rf "$path"
      ok "mujoco venv removed"
    else
      skip "mujoco venv kept"
    fi
  else
    skip "mujoco venv not present"
  fi
}

dispatch "$@"
