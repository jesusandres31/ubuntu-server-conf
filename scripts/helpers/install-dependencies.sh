#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

require_root
load_config

[ -r /etc/os-release ] || die "/etc/os-release is not readable"
# shellcheck disable=SC1091
source /etc/os-release
[ "${ID:-}" = "ubuntu" ] || die "this bootstrap script supports Ubuntu only"
[ -n "${SERVER_HOSTNAME:-}" ] || die "SERVER_HOSTNAME must be set in $CONFIG_FILE"
[[ "$SERVER_HOSTNAME" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*$ ]] || die "invalid SERVER_HOSTNAME: $SERVER_HOSTNAME"
SERVER_TIMEZONE="${SERVER_TIMEZONE:-Etc/UTC}"

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y ca-certificates curl exfatprogs git iproute2 netplan.io openssh-server unzip util-linux

if ! command -v rclone >/dev/null 2>&1 || ! rclone help backends 2>/dev/null | grep -Eq '(^|[[:space:]])mega($|[[:space:]])'; then
  curl -fsSL https://rclone.org/install.sh | bash
fi

if ! docker compose version >/dev/null 2>&1; then
  conflicting_packages=""
  for package_name in docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc; do
    if dpkg-query -W -f='${db:Status-Status}' "$package_name" 2>/dev/null | grep -qx installed; then
      conflicting_packages="$conflicting_packages $package_name"
    fi
  done

  [ -z "$conflicting_packages" ] || die "remove conflicting Docker packages before continuing:$conflicting_packages"

  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc

  ubuntu_codename="${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}"
  [ -n "$ubuntu_codename" ] || die "could not determine the Ubuntu codename"
  architecture=$(dpkg --print-architecture)

  cat > /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $ubuntu_codename
Components: stable
Architectures: $architecture
Signed-By: /etc/apt/keyrings/docker.asc
EOF

  apt-get update
  apt-get install -y containerd.io docker-buildx-plugin docker-ce docker-ce-cli docker-compose-plugin
fi

hostnamectl set-hostname "$SERVER_HOSTNAME"
timedatectl set-timezone "$SERVER_TIMEZONE"
systemctl enable --now ssh docker

echo "Bootstrap complete for $SERVER_HOSTNAME."
timedatectl | grep 'Time zone'
docker --version
docker compose version
