#!/usr/bin/env bash
# Delegate to each cloned repo's own installer (nish-aliases, nish-ai, fm-ros2).
set -euo pipefail
source "$(dirname "$0")/../lib.sh"
require_macos

do_check()     { run_repo_installers check macos; }
do_install()   { run_repo_installers install macos; }
do_uninstall() { run_repo_installers uninstall macos; }

dispatch "$@"
