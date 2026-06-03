# Workstation Setup

> Steps for setting up First Motive's workstation. Source-of-truth narrative; the automated version lives in `scripts/ubuntu/`.

## On the MacBook (preflight)

- **balenaEtcher** — to write the install media
- **Ubuntu 22.04.5 LTS Desktop ISO**
- **Tailscale**

## Workstation install (manual, in the Ubuntu installer)

- Minimal Installation
- Install Third-Party Software
- Use LVM

## Workstation Installations

### Update System

```bash
sudo apt update
sudo apt upgrade
sudo reboot
```

### Install Dependencies

```bash
sudo apt install curl git openssh-server -y
```

### Tools

- **Claude Code** — `curl -fsSL https://claude.ai/install.sh | bash`
- **GH CLI** — `sudo apt install gh` (after adding the GitHub apt repo)
- **NVIDIA Drivers** — `sudo ubuntu-drivers install` and `sudo apt install nvidia-driver-580-open -y`
  - **595 is too new and is incompatible with Isaac Sim.**
- **Tailscale** — `curl -fsSL https://tailscale.com/install.sh | sh`
- **UV** — `curl -Ls https://astral.sh/uv/install.sh | sh`

### Download

- Google Chrome
- Slack
- VS Code
- Foxglove Studio

### Claude Code Plugins

- **Cloudflare** — `claude plugin install cloudflare@claude-plugins-official`
  - Bundles 8 skills: `cloudflare`, `wrangler`, `durable-objects`, `agents-sdk`, `sandbox-sdk`, `workers-best-practices`, `cloudflare-email-service`, `web-perf`

### Sign In

- **GitHub** — `gh auth login`
- **Claude Code** — `claude /login`

### Shortcuts

#### Bash Aliases

```bash
cat << 'EOF' > ~/.bash_aliases
# System
alias c='clear'
alias update='sudo apt update && sudo apt upgrade'

# GitHub
alias add='git add .'
alias commit='git commit -m '
alias push='git push'

alias mj='source ~/.venvs/mujoco/bin/activate'
alias lr='source ~/.venvs/lerobot/bin/activate'
EOF
```

#### Passwordless sudo

```bash
sudo visudo -f /etc/sudoers.d/nopasswd_users
# <username> ALL=(ALL) NOPASSWD: ALL
```

## Install Software

### ROS 2

- Configure environment variables
- `sudo rosdep init`
- **ROS 2 Control** — `sudo apt install ros-humble-ros2-control ros-humble-ros2-controllers -y`
- **MoveIt** — `sudo apt install ros-humble-moveit ros-humble-rqt-joint-trajectory-controller ros-humble-moveit-servo -y`
- **Foxglove Bridge** — `sudo apt install ros-humble-foxglove-bridge`

### Isaac Sim

Download + install per NVIDIA's instructions (account required).

### Mujoco

```bash
uv venv ~/.venvs/mujoco --python 3.11
source ~/.venvs/mujoco/bin/activate
uv pip install mujoco

# Test
python -c "import mujoco; print(mujoco.__version__)"
python -m mujoco.viewer
```

### LeRobot

```bash
uv venv ~/.venvs/lerobot --python 3.11
source ~/.venvs/lerobot/bin/activate
uv pip install lerobot
```

### OpenArm

```bash
mkdir -p ~/openarm_ws/src
cd ~/openarm_ws/src
gh repo clone enactic/openarm_ros2
gh repo clone enactic/openarm_description
gh repo clone enactic/openarm_mujoco
touch openarm_mujoco/COLCON_IGNORE
vcs import . < openarm_ros2/openarm.repos
cd ..
rosdep update && rosdep install --from-paths src --ignore-src -r -y
sudo apt install -y libcli11-dev   # missing dep
```

### Hugging Face CLI

```bash
uv tool install huggingface_hub
huggingface-cli login
```

## Connect Remotely from the MacBook

### SSH

- Enable on workstation: `sudo systemctl enable ssh`
- Copy SSH key from MacBook: `ssh-copy-id <user>@first-motive-ws`
- Connect: `ssh <user>@first-motive-ws`

### Tailscale

Authenticate with `sudo tailscale up` on both machines.
