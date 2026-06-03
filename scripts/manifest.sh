#!/usr/bin/env bash
# Central manifest: the single source of truth for what nish-ignition installs.
# Data only — no logic. Sourced by lib.sh, so every step sees these arrays.
#
# Step registry entries are "id|file|default" strings:
#   id      stable handle used by --skip / --only / --list
#   file    script under scripts/<os>/
#   default on | off — whether the step runs in a plain ./setup.sh
#
# Indexed arrays of pipe-delimited strings (not associative arrays) keep this
# portable to the macOS system bash 3.2.

# --- Step registries -------------------------------------------------------

MACOS_STEPS=(
  "homebrew|00-homebrew.sh|on"
  "cli-tools|10-cli-tools.sh|on"
  "claude-code|20-claude-code.sh|on"
  "apps|30-apps.sh|on"
  "accounts|40-accounts.sh|on"
  "signin|50-signin.sh|on"
  "ssh-key|60-ssh-key.sh|on"
  "python-envs|70-python-envs.sh|on"
  "huggingface|80-huggingface.sh|on"
)

UBUNTU_STEPS=(
  "system-update|00-system-update.sh|on"
  "base-deps|10-base-deps.sh|on"
  "cli-tools|20-cli-tools.sh|on"
  "nvidia|30-nvidia.sh|on"
  "tailscale|40-tailscale.sh|on"
  "apps|50-apps.sh|on"
  "signin|60-signin.sh|on"
  "ssh-server|65-ssh-server.sh|on"
  "sudo-nopasswd|75-sudo-nopasswd.sh|on"
  "ros2|80-ros2.sh|on"
  "python-envs|82-python-envs.sh|on"
  "openarm|84-openarm.sh|on"
  "huggingface|86-huggingface.sh|on"
  "isaac-sim|88-isaac-sim.sh|on"
)

# --- Package arrays --------------------------------------------------------

MACOS_FORMULAE=(gh uv python cloudflare-wrangler jq)

MACOS_CASKS=(
  slack
  claude
  visual-studio-code
  google-drive
  foxglove-studio
  orbstack
)

# Base apt deps installed early on Ubuntu. jq mirrors the macOS formula.
UBUNTU_APT=(
  curl
  git
  openssh-server
  ca-certificates
  gnupg
  lsb-release
  software-properties-common
  jq
)

# ROS 2 Humble package set.
UBUNTU_ROS_APT=(
  ros-humble-desktop
  ros-humble-ros2-control
  ros-humble-ros2-controllers
  ros-humble-moveit
  ros-humble-rqt-joint-trajectory-controller
  ros-humble-moveit-servo
  ros-humble-foxglove-bridge
  python3-rosdep
  python3-colcon-common-extensions
  python3-vcstool
)
