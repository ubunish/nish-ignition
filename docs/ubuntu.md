# Workstation Setup

> Reference narrative. The automated flow in `./setup.sh` (see the [README](../README.md)) supersedes the manual steps below — run that first. This guide is kept for context, debugging, and the steps that still need a human (Ubuntu installer choices, BIOS, manual downloads).

## On the MacBook (preflight)

- **balenaEtcher** — to write the install media
- **Ubuntu 22.04.5 LTS Desktop ISO** — <https://releases.ubuntu.com/jammy/>, file named like `ubuntu-22.04.5-desktop-amd64.iso`
- **Tailscale**

Use the **`.5`** point release specifically. It ships the HWE 6.8 kernel, which carries the AMD chipset and NVIDIA support the Zen 5 / X870E / RTX 5090 hardware needs. The original 22.04 GA kernel (5.15) may not reach the installer on this board.

Flash with Etcher: **Flash from file** → the ISO, **Select target** → the USB (check the size — wrong target wipes the wrong disk), **Flash**. macOS reports "Disk Not Readable" when done — that is expected (it cannot read Linux partitions); click **Eject**, not Initialise. Use a **rear** motherboard USB port for the install — front-panel ports are sometimes missed during boot.

## BIOS prep (ASUS ProArt X870E)

Power on, tap `Delete` repeatedly at the ASUS logo to enter BIOS, then `F7` for Advanced Mode. Set four things:

| Setting | Where | Set to |
|---|---|---|
| **EXPO / DOCP** (RAM speed) | Ai Tweaker → Ai Overclock Tuner | **EXPO I** — runs DDR5-6000 at rated 6000 MT/s instead of 4800 |
| **Secure Boot** | Boot → Secure Boot → OS Type | **Other OS** — required for the proprietary NVIDIA driver to load without MOK signing |
| **Resizable BAR** | Advanced → PCI Subsystem Settings → Re-Size BAR Support | **Enabled** — perf win for the RTX 5090 |
| **Boot order** | Boot → Boot Option Priorities → Boot Option #1 | The install USB |

`F10` → Save & Exit. If you skip boot order, tap `F8` at the ASUS splash for a one-time boot menu and pick the USB.

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

## Troubleshooting

| Symptom | Likely fix |
|---|---|
| `nvidia-smi` says "No devices were found" after install | Almost always Secure Boot. Reboot into BIOS (`Delete`), Boot → Secure Boot → OS Type → **Other OS**, save, reboot. |
| Black screen after first reboot post-driver-install | Hold `Shift` during boot for the GRUB menu → Advanced options → boot the previous kernel. Then `sudo apt purge nvidia-*`, `sudo apt autoremove`, `sudo reboot`, and reinstall the driver one version below the recommended. |
| Wi-Fi not working on first boot | "Install third-party software" was skipped in the installer. Plug in Ethernet, run `sudo apt install -y linux-firmware`, reboot. |
| Isaac Sim crashes on launch | Check VRAM with `nvidia-smi` — Isaac Sim needs at least 8 GB free. Close whatever else holds the GPU. |
| Installer froze on "Updating partition tables" | Power off (hold power 10s), unplug power 30s, plug back in, retry. The X870E sometimes needs a full power cycle to commit NVMe partition changes the first time. |
