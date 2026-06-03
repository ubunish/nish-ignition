#!/usr/bin/env bash
# ROS 2 Humble + ros2-control, MoveIt, Foxglove bridge.
set -euo pipefail
source "$(dirname "$0")/../lib.sh"
require_linux

CODENAME="$(. /etc/os-release && echo "$VERSION_CODENAME")"
if [[ "$CODENAME" != "jammy" ]]; then
  warn "ROS 2 Humble targets Ubuntu 22.04 (jammy); detected '$CODENAME'. Proceeding anyway."
fi

# Add ROS 2 apt repo if missing
if [[ ! -f /etc/apt/sources.list.d/ros2.list ]]; then
  log "Adding ROS 2 apt repo"
  sudo apt-get install -y software-properties-common
  sudo add-apt-repository universe -y
  sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
    -o /usr/share/keyrings/ros-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $CODENAME main" \
    | sudo tee /etc/apt/sources.list.d/ros2.list >/dev/null
  sudo apt-get update
fi

ROS_PACKAGES=(
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

MISSING=()
for p in "${ROS_PACKAGES[@]}"; do
  if dpkg -s "$p" >/dev/null 2>&1; then
    skip "$p"
  else
    MISSING+=("$p")
  fi
done

if ((${#MISSING[@]})); then
  log "apt install ROS packages: ${MISSING[*]}"
  sudo apt-get install -y "${MISSING[@]}"
fi

# rosdep init (only once per machine)
if [[ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]]; then
  log "rosdep init"
  sudo rosdep init
fi
log "rosdep update"
rosdep update

# Source ROS in ~/.bashrc
if ! grep -q '/opt/ros/humble/setup.bash' "$HOME/.bashrc"; then
  echo 'source /opt/ros/humble/setup.bash' >> "$HOME/.bashrc"
  ok "Added ROS source line to ~/.bashrc"
fi

ok "ROS 2 Humble ready"
