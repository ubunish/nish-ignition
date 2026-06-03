#!/usr/bin/env bash
# Hugging Face CLI as a uv-managed tool.
set -euo pipefail
source "$(dirname "$0")/../lib.sh"
has_cmd uv || { err "uv missing — run 10-cli-tools.sh first"; exit 1; }

if has_cmd huggingface-cli; then
  ok "huggingface-cli already installed"
else
  log "uv tool install huggingface_hub"
  uv tool install huggingface_hub
  ok "huggingface-cli installed"
fi

info "Sign in with: huggingface-cli login"
pause "Run 'huggingface-cli login' when you have your HF token ready."
