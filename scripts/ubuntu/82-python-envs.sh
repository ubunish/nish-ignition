#!/usr/bin/env bash
# Robotics Python envs via uv: mujoco + lerobot in ~/.venvs/<name>.
set -euo pipefail
source "$(dirname "$0")/../lib.sh"
has_cmd uv || { err "uv missing — run 20-cli-tools.sh first"; exit 1; }

make_env() {
  local name="$1" pkg="$2" path="$HOME/.venvs/$name"
  if [[ -d "$path" ]]; then
    skip "$name venv exists at $path"
    return
  fi
  log "Creating $name venv at $path"
  uv venv "$path" --python 3.11
  # shellcheck disable=SC1090
  source "$path/bin/activate"
  uv pip install "$pkg"
  deactivate
  ok "$name ready (activate: source $path/bin/activate)"
}

make_env mujoco  mujoco
make_env lerobot lerobot
