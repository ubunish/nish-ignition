#!/usr/bin/env bash
# Isaac Sim — manual download required (NVIDIA account). Print + pause.
set -euo pipefail
source "$(dirname "$0")/../lib.sh"

do_check() {
  info "Isaac Sim installs manually — install state is not machine-checkable."
  return 0
}

do_install() {
  cat <<'EOF'
    Isaac Sim install (manual):

      1. Sign in with your NVIDIA developer account:
         https://developer.nvidia.com/isaac-sim

      2. Download the latest Isaac Sim 4.x for Linux that matches
         your installed NVIDIA driver (this repo pins 580-open).
         NVIDIA driver 595 is NOT compatible with Isaac Sim.

      3. Follow NVIDIA's install guide:
         https://docs.isaacsim.omniverse.nvidia.com/latest/installation/install_workstation.html

EOF
  pause "Complete the Isaac Sim install, then continue."
}

do_uninstall() {
  info "Isaac Sim installs manually — remove it through NVIDIA's uninstaller or by deleting its install directory."
  return 0
}

dispatch "$@"
