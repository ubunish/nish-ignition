#!/usr/bin/env bash
# Robotics Python envs via uv: mujoco + lerobot in ~/.venvs/<name>.
set -euo pipefail
source "$(dirname "$0")/../lib.sh"
has_cmd uv || { err "uv missing — run 10-cli-tools.sh first"; exit 1; }

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

check_env() {
  local name="$1" path="$HOME/.venvs/$name"
  if [[ -d "$path" ]]; then
    ok "$name venv exists at $path"
  else
    warn "$name venv not found at $path"
  fi
}

remove_env() {
  local name="$1" path="$HOME/.venvs/$name"
  if [[ ! -d "$path" ]]; then
    skip "$name venv not found at $path"
    return
  fi
  if confirm "Delete $name venv at $path? This removes its packages."; then
    rm -rf "$path"
    ok "$name venv removed"
  else
    skip "$name venv left in place"
  fi
}

do_check() {
  check_env mujoco
  check_env lerobot
  return 0
}

do_install() {
  make_env mujoco  mujoco
  make_env lerobot lerobot

  info "Smoke-test mujoco with: source ~/.venvs/mujoco/bin/activate && python -m mujoco.viewer"
}

do_uninstall() {
  # Venvs are reproducible user data — reverse, but gate the delete behind confirm.
  remove_env mujoco
  remove_env lerobot
}

dispatch "$@"
