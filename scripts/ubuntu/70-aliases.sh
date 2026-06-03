#!/usr/bin/env bash
# Bash aliases.
set -euo pipefail
source "$(dirname "$0")/../lib.sh"

ALIASES="$HOME/.bash_aliases"

if [[ -f "$ALIASES" ]] && grep -q '# first-motive-docs aliases' "$ALIASES"; then
  ok "aliases already in $ALIASES"
  exit 0
fi

cat >> "$ALIASES" <<'EOF'

# first-motive-docs aliases
# System
alias c='clear'
alias update='sudo apt update && sudo apt upgrade'

# Git
alias add='git add .'
alias commit='git commit -m '
alias push='git push'

# Robotics venvs
alias mj='source ~/.venvs/mujoco/bin/activate'
alias lr='source ~/.venvs/lerobot/bin/activate'
EOF

ok "Appended aliases to $ALIASES"
info "Reload your shell or 'source ~/.bashrc' to pick them up."
