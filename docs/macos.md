# MacBook Pro Setup

> Reference narrative. The automated flow in `./setup.sh` (see the [README](../README.md)) supersedes the manual steps below — run that first. This guide is kept for context, debugging, and the steps that still need a human.

## Create Accounts

- Google `@ubundi.co.za`
- Claude
- Wise

## Download

- Slack
- Claude
- VS Code
- Google Drive
- Foxglove

## Install

- **Homebrew** — `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
- **Claude Code** — `curl -fsSL https://claude.ai/install.sh | bash`
- **GH CLI** — `brew install gh`
- **UV** (fast Python package installer) — `brew install uv`
- **Python** — `brew install python`
- **Cloudflare Wrangler** — `brew install cloudflare-wrangler`
- **OrbStack** — `brew install --cask orbstack`

## Claude Code Plugins

- **Cloudflare** — `claude plugin install cloudflare@claude-plugins-official`
  - Bundles 8 skills: `cloudflare`, `wrangler`, `durable-objects`, `agents-sdk`, `sandbox-sdk`, `workers-best-practices`, `cloudflare-email-service`, `web-perf`

## Sign In

- **GitHub** — `gh auth login`
- **Claude Code** — `claude /login`

## Setup

- **SSH Key** — `ssh-keygen -t ed25519 -C "<user>@ubundi.co.za"`

## Robotics Installations

### Mujoco

```bash
uv venv ~/.venvs/mujoco --python 3.11
source ~/.venvs/mujoco/bin/activate
uv pip install mujoco

# Test
python -c "import mujoco; print(mujoco.__version__)"
python -m mujoco.viewer  # interactive viewer with a demo scene
```

### LeRobot

```bash
uv venv ~/.venvs/lerobot --python 3.11
source ~/.venvs/lerobot/bin/activate
uv pip install lerobot
```

### Hugging Face CLI

```bash
uv tool install huggingface_hub
huggingface-cli login
```

### Aliases

```bash
echo 'alias mj="source ~/.venvs/mujoco/bin/activate"' >> ~/.zshrc
echo 'alias lr="source ~/.venvs/lerobot/bin/activate"' >> ~/.zshrc
source ~/.zshrc
```
