#!/usr/bin/env bash
# Claude Code, gh CLI, uv.
set -euo pipefail
source "$(dirname "$0")/../lib.sh"
require_linux

# Claude Code
if has_cmd claude; then
  ok "Claude Code already installed"
else
  log "Installing Claude Code"
  curl -fsSL https://claude.ai/install.sh | bash
  ok "Claude Code installed"
fi

# Cloudflare plugin — bundles cloudflare, wrangler, durable-objects, agents-sdk,
# sandbox-sdk, workers-best-practices, cloudflare-email-service, web-perf skills.
if claude plugin list 2>/dev/null | grep -q '^cloudflare\b'; then
  ok "cloudflare plugin already installed"
else
  log "Installing cloudflare Claude Code plugin"
  claude plugin marketplace add anthropics/claude-plugins-official >/dev/null 2>&1 || true
  claude plugin install cloudflare@claude-plugins-official
  ok "cloudflare plugin installed"
fi

# gh CLI — needs the GitHub apt repo on Ubuntu 22.04
if has_cmd gh; then
  ok "gh already installed"
else
  log "Adding GitHub CLI apt repo + installing gh"
  KEYRING=/usr/share/keyrings/githubcli-archive-keyring.gpg
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | sudo dd of="$KEYRING" status=none
  sudo chmod go+r "$KEYRING"
  echo "deb [arch=$(dpkg --print-architecture) signed-by=$KEYRING] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  sudo apt-get update
  sudo apt-get install -y gh
  ok "gh installed"
fi

# uv
if has_cmd uv; then
  ok "uv already installed"
else
  log "Installing uv"
  curl -Ls https://astral.sh/uv/install.sh | sh
  ok "uv installed"
  info "Open a new shell or 'source ~/.bashrc' to pick up the uv PATH change."
fi
