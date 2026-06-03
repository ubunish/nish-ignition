#!/usr/bin/env bash
# Shared helpers for setup scripts. Source, don't execute.

set -euo pipefail

# Pull in the manifest (step registries + package arrays). Sourcing here means
# every step that sources lib.sh also sees the manifest arrays.
# shellcheck source=scripts/manifest.sh
source "$(dirname "${BASH_SOURCE[0]}")/manifest.sh"

BOLD=$'\e[1m'; DIM=$'\e[2m'; RED=$'\e[31m'; GREEN=$'\e[32m'; YELLOW=$'\e[33m'; BLUE=$'\e[34m'; RESET=$'\e[0m'

log()    { printf '%s\n' "${BLUE}==>${RESET} ${BOLD}$*${RESET}"; }
info()   { printf '%s\n' "    $*"; }
ok()     { printf '%s\n' "${GREEN}    ✓${RESET} $*"; }
skip()   { printf '%s\n' "${DIM}    ↷ $* (skip)${RESET}"; }
warn()   { printf '%s\n' "${YELLOW}    !${RESET} $*"; }
err()    { printf '%s\n' "${RED}    ✗${RESET} $*" >&2; }

has_cmd() { command -v "$1" >/dev/null 2>&1; }

# pause "message" — print and wait for Enter (skipped under NONINTERACTIVE=1)
pause() {
  if [[ "${NONINTERACTIVE:-0}" == "1" ]]; then
    warn "$* (NONINTERACTIVE — skipping pause)"
    return
  fi
  printf '%s\n' "${YELLOW}    →${RESET} $*"
  read -r -p "    Press Enter to continue… " _
}

# confirm "question" — y/N prompt; returns 0 on yes (auto-no under NONINTERACTIVE=1)
confirm() {
  if [[ "${NONINTERACTIVE:-0}" == "1" ]]; then
    warn "$* — auto-declined (NONINTERACTIVE)"
    return 1
  fi
  local reply
  read -r -p "    ${YELLOW}?${RESET} $* [y/N] " reply
  [[ "$reply" =~ ^[Yy]$ ]]
}

require_macos() { [[ "$(uname -s)" == "Darwin" ]] || { err "macOS only"; exit 1; }; }
require_linux() { [[ "$(uname -s)" == "Linux"  ]] || { err "Linux only";  exit 1; }; }

# --- Step gating -----------------------------------------------------------
# setup.sh fills DISABLED (from --skip) and ONLY (from --only) before iterating
# the manifest. These default empty so a step sourced standalone always runs.
DISABLED=("${DISABLED[@]:-}")
ONLY=("${ONLY[@]:-}")

# _in_list NEEDLE ITEM... — 0 if NEEDLE equals one of the ITEMs.
_in_list() {
  local needle="$1"; shift
  local item
  for item in "$@"; do
    [[ "$item" == "$needle" ]] && return 0
  done
  return 1
}

# is_enabled ID DEFAULT — decide whether step ID runs.
#   --only set   → run only ids in ONLY
#   id in DISABLED → skip
#   otherwise    → follow DEFAULT (on|off)
is_enabled() {
  local id="$1" default="$2"
  if ((${#ONLY[@]})) && [[ -n "${ONLY[0]:-}" ]]; then
    _in_list "$id" "${ONLY[@]}"
    return
  fi
  if ((${#DISABLED[@]})) && [[ -n "${DISABLED[0]:-}" ]]; then
    _in_list "$id" "${DISABLED[@]}" && return 1
  fi
  [[ "$default" == "on" ]]
}

# dispatch [MODE] — route a retrofitted step to its do_<mode> function.
# Steps define do_check / do_install / do_uninstall, then call: dispatch "$@"
dispatch() {
  local mode="${1:-install}"
  case "$mode" in
    check)     do_check ;;
    install)   do_install ;;
    uninstall) do_uninstall ;;
    *) err "unknown mode: $mode (use check|install|uninstall)"; exit 1 ;;
  esac
}

# --- Repo layer ------------------------------------------------------------
# Where Nish's own repos are cloned. Override with CODE_DIR for testing.
CODE_DIR="${CODE_DIR:-$HOME/code}"

# repo_root — absolute path to the nish-ignition checkout (repos.yaml lives here).
repo_root() { cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd; }

# import_repos — clone every repo in repos.yaml into CODE_DIR via vcstool.
# Idempotent: vcs import skips repos already present.
import_repos() {
  has_cmd vcs || { err "vcstool (vcs) missing — install it before importing"; return 1; }
  local repos_file; repos_file="$(repo_root)/repos.yaml"
  [[ -f "$repos_file" ]] || { err "repos.yaml not found at $repos_file"; return 1; }
  mkdir -p "$CODE_DIR"
  log "vcs import $CODE_DIR < repos.yaml"
  vcs import "$CODE_DIR" <"$repos_file"
  ok "repos imported into $CODE_DIR"
}

# _delegate_contract INSTALLER MODE — run a cloned repo's install.sh, mapping
# nish-ignition's mode to the repo's {install|uninstall|status} contract.
# Both nish-aliases and nish-ai implement this contract.
_delegate_contract() {
  local installer="$1" mode="$2" arg
  case "$mode" in
    install)   arg="install"   ;;
    uninstall) arg="uninstall" ;;
    check)     arg="status"    ;;
  esac
  if [[ -x "$installer" ]]; then
    log "delegate: $installer $arg"
    "$installer" "$arg"
  else
    warn "installer not found (repo not cloned?): $installer"
  fi
}

# _delegate_fm_ros2 DIR MODE OS — fm-ros2 owns its Docker/colcon/externals and
# exposes only a per-OS setup script, so only the install mode delegates.
_delegate_fm_ros2() {
  local dir="$1" mode="$2" os="$3" setup="$1/scripts/setup-$3.sh"
  case "$mode" in
    install)
      if [[ -x "$setup" ]]; then
        log "delegate: $setup"
        "$setup"
      else
        warn "fm-ros2 setup not found (repo not cloned?): $setup"
      fi
      ;;
    *)
      info "fm-ros2 has no $mode entrypoint — skipping (it owns its own lifecycle)"
      ;;
  esac
}

# run_repo_installers MODE OS — delegate to every cloned repo's own entrypoint.
run_repo_installers() {
  local mode="$1" os="$2"
  _delegate_contract "$CODE_DIR/nish-aliases/install.sh" "$mode"
  _delegate_contract "$CODE_DIR/nish-ai/install.sh" "$mode"
  _delegate_fm_ros2 "$CODE_DIR/fm-ros2" "$mode" "$os"
}
