#!/usr/bin/env bash
# Robotics Python envs via uv: mujoco + lerobot in ~/.venvs/<name>.
set -euo pipefail
source "$(dirname "$0")/../lib.sh"
has_cmd uv || { err "uv missing — run 20-cli-tools.sh first"; exit 1; }

do_check() {
  local name path
  for name in mujoco lerobot; do
    path="$HOME/.venvs/$name"
    [[ -d "$path" ]] && ok "$name venv at $path" || warn "$name venv missing"
  done
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

  make_env mujoco  mujoco
  make_env lerobot lerobot
}

do_uninstall() {
  local name path
  for name in mujoco lerobot; do
    path="$HOME/.venvs/$name"
    if [[ -d "$path" ]]; then
      if confirm "Remove $name venv at $path?"; then
        rm -rf "$path"
        ok "$name venv removed"
      else
        skip "$name venv kept"
      fi
    else
      skip "$name venv not present"
    fi
  done
}

dispatch "$@"
