#!/usr/bin/env bash
# Manual account creation — can't be scripted. Pauses for the operator.
set -euo pipefail
source "$(dirname "$0")/../lib.sh"

cat <<'EOF'
    Create the following accounts (skip any you already have):

      • Google         @ubundi.co.za workspace account
      • Claude         https://claude.ai/login
      • Wise           https://wise.com/register

EOF
pause "Create accounts in your browser, then continue."
