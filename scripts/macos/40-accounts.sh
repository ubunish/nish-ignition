#!/usr/bin/env bash
# Manual account creation — can't be scripted. Pauses for the operator.
set -euo pipefail
source "$(dirname "$0")/../lib.sh"

do_check() {
  info "Account creation is manual — cannot verify state programmatically"
  return 0
}

do_install() {
  cat <<'EOF'
    Create the following accounts (skip any you already have):

      • Google         @ubundi.co.za workspace account
      • Claude         https://claude.ai/login
      • Wise           https://wise.com/register

EOF
  pause "Create accounts in your browser, then continue."
}

do_uninstall() {
  # Accounts live with external providers — never removable from here.
  warn "Accounts left in place — close them manually with each provider if needed"
}

dispatch "$@"
