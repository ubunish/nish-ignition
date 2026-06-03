#!/usr/bin/env bash
# OpenArm ROS 2 workspace under ~/openarm_ws.
set -euo pipefail
source "$(dirname "$0")/../lib.sh"
require_linux

WS="$HOME/openarm_ws"
SRC="$WS/src"

do_check() {
  [[ -d "$WS" ]] && ok "OpenArm workspace at $WS" || warn "OpenArm workspace missing"
  return 0
}

do_install() {
  has_cmd gh    || { err "gh missing — run 20-cli-tools.sh first"; exit 1; }
  has_cmd vcs   || { err "vcstool missing — run 80-ros2.sh first"; exit 1; }
  has_cmd rosdep || { err "rosdep missing — run 80-ros2.sh first"; exit 1; }

  mkdir -p "$SRC"
  cd "$SRC"

  clone_if_missing() {
    local repo="$1" dir
    dir="$(basename "$repo")"
    if [[ -d "$dir" ]]; then
      skip "$dir already cloned"
    else
      log "gh repo clone $repo"
      gh repo clone "$repo"
    fi
  }

  clone_if_missing enactic/openarm_ros2
  clone_if_missing enactic/openarm_description
  clone_if_missing enactic/openarm_mujoco

  # Tell colcon to ignore the mujoco package
  touch openarm_mujoco/COLCON_IGNORE

  log "vcs import < openarm_ros2/openarm.repos"
  vcs import . < openarm_ros2/openarm.repos

  cd "$WS"

  # Missing dep noted in the original guide
  if ! dpkg -s libcli11-dev >/dev/null 2>&1; then
    log "apt install libcli11-dev (missing OpenArm dep)"
    sudo apt-get install -y libcli11-dev
  fi

  log "rosdep install"
  rosdep update
  rosdep install --from-paths src --ignore-src -r -y

  ok "OpenArm workspace ready at $WS"
  info "Build with: cd $WS && colcon build"
}

do_uninstall() {
  if [[ -d "$WS" ]]; then
    if confirm "Remove OpenArm workspace at $WS?"; then
      rm -rf "$WS"
      ok "OpenArm workspace removed"
    else
      skip "OpenArm workspace kept"
    fi
  else
    skip "OpenArm workspace not present"
  fi
}

dispatch "$@"
