#!/usr/bin/env bash
# Claude Code CLI (official installer) + Cloudflare plugin.
set -euo pipefail
source "$(dirname "$0")/../lib.sh"
require_macos

if has_cmd claude; then
  ok "Claude Code already installed ($(claude --version 2>/dev/null | head -1))"
else
  log "Installing Claude Code"
  curl -fsSL https://claude.ai/install.sh | bash
  ok "Claude Code installed"
  info "Sign in later with: claude /login"
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
