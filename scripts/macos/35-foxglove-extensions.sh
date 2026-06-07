#!/usr/bin/env bash
# Foxglove Studio extensions: build from source and install into the native app.
#
# Foxglove Studio (installed by 30-apps as a brew cask) loads unpacked
# extensions from ~/.foxglove-studio/extensions/<publisher>.<name>-<version>/.
# Each extension here is a TypeScript project built with the @foxglove/extension
# CLI; `npm run local-install` builds it and copies the result into that dir.
#
# The extension list lives in the manifest (MACOS_FOXGLOVE_EXTENSIONS), one
# entry per line as: name|repo_url|install_glob[|subdir]
#   name          short handle, also the clone dir under the build cache
#   repo_url      git remote, cloned at default-branch HEAD (tracks main)
#   install_glob  pattern under the extensions dir that means "installed"
#   subdir        optional path within the repo to the extension's package.json
#                 (defaults to the repo root)
#
# Sources are cloned into a build cache (XDG_CACHE_HOME) so re-runs pull instead
# of re-cloning. Install is idempotent: an extension whose install_glob already
# matches is skipped. To pick up upstream changes, uninstall then install.
set -euo pipefail
source "$(dirname "$0")/../lib.sh"
require_macos

EXT_DIR="$HOME/.foxglove-studio/extensions"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/nish-setup/foxglove-extensions"

# _installed GLOB — 0 if any directory under EXT_DIR matches GLOB.
_installed() { compgen -G "$EXT_DIR/$1" >/dev/null 2>&1; }

do_check() {
  local entry name repo glob subdir
  for entry in "${MACOS_FOXGLOVE_EXTENSIONS[@]}"; do
    IFS='|' read -r name repo glob subdir <<<"$entry"
    if _installed "$glob"; then
      ok "$name installed"
    else
      warn "$name not installed"
    fi
  done
  return 0
}

do_install() {
  has_cmd git || { err "git missing — run 10-cli-tools.sh first"; exit 1; }
  has_cmd npm || { err "npm missing — install Node: brew install node"; exit 1; }

  local entry name repo glob subdir dir
  for entry in "${MACOS_FOXGLOVE_EXTENSIONS[@]}"; do
    IFS='|' read -r name repo glob subdir <<<"$entry"
    if _installed "$glob"; then
      skip "$name (uninstall first to rebuild)"
      continue
    fi

    dir="$CACHE_DIR/$name"
    if [[ -d "$dir/.git" ]]; then
      log "git pull $name"
      git -C "$dir" pull --ff-only
    else
      log "git clone $name"
      rm -rf "$dir"
      mkdir -p "$CACHE_DIR"
      git clone --depth 1 "$repo" "$dir"
    fi

    log "npm install + local-install ($name)"
    ( cd "$dir/${subdir:-.}" && npm install && npm run local-install )
    ok "$name"
  done

  info "Restart Foxglove Studio to load newly installed extensions."
}

do_uninstall() {
  local entry name repo glob subdir match
  for entry in "${MACOS_FOXGLOVE_EXTENSIONS[@]}"; do
    IFS='|' read -r name repo glob subdir <<<"$entry"
    if _installed "$glob"; then
      log "remove $name"
      while IFS= read -r match; do
        rm -rf "$match"
      done < <(compgen -G "$EXT_DIR/$glob")
      ok "$name removed"
    else
      skip "$name not installed"
    fi
    rm -rf "${CACHE_DIR:?}/$name"
  done
}

dispatch "$@"
