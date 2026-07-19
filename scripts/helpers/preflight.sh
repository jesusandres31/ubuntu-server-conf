#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

errors=0
warnings=0

ok() {
  echo "[OK]   $*"
}

warn() {
  echo "[WARN] $*"
  warnings=$((warnings + 1))
}

fail() {
  echo "[FAIL] $*"
  errors=$((errors + 1))
}

check_command() {
  if command -v "$1" >/dev/null 2>&1; then
    ok "$1 is installed"
  else
    fail "$1 is not installed"
  fi
}

echo "Preflight for $CONFIG_FILE"

if [ -r /etc/os-release ]; then
  # shellcheck disable=SC1091
  source /etc/os-release
  if [ "${ID:-}" = "ubuntu" ]; then
    ok "operating system is ${PRETTY_NAME:-Ubuntu}"
  else
    fail "this repository expects Ubuntu; found ${PRETTY_NAME:-unknown}"
  fi
else
  fail "/etc/os-release is not readable"
fi

for command_name in ip netplan blkid findmnt mountpoint awk install timedatectl docker; do
  check_command "$command_name"
done

if [ -f "$CONFIG_FILE" ]; then
  load_config
  ok "configuration file exists"
else
  fail "missing $CONFIG_FILE (copy .env.example first)"
fi

for variable_name in SERVER_HOSTNAME SERVER_USER SERVER_TIMEZONE ETH_IFACE ETH_ADDRESS GATEWAY DNS DISK_UUID MOUNT_POINT FS_TYPE MOUNT_OPTIONS SHARE_DIR; do
  if [[ -v $variable_name ]] && [ -n "${!variable_name}" ]; then
    ok "$variable_name is configured"
  else
    fail "$variable_name is empty in $CONFIG_FILE"
  fi
done

if [ -n "${SERVER_USER:-}" ] && id "$SERVER_USER" >/dev/null 2>&1; then
  ok "server user exists: $SERVER_USER"
else
  fail "SERVER_USER does not identify an existing account"
fi

if [ -n "${SERVER_TIMEZONE:-}" ] && timedatectl list-timezones | grep -Fx "$SERVER_TIMEZONE" >/dev/null 2>&1; then
  ok "server timezone is valid: $SERVER_TIMEZONE"
else
  fail "SERVER_TIMEZONE is not a valid timezone"
fi

if [ -n "${ETH_IFACE:-}" ] && [ "$ETH_IFACE" != "REPLACE_WITH_INTERFACE" ] && ip link show "$ETH_IFACE" >/dev/null 2>&1; then
  ok "network interface exists: $ETH_IFACE"
else
  fail "ETH_IFACE is not configured; find it with: ip link"
fi

MOUNT_POINT="${MOUNT_POINT:-/mnt/ssd}"
if [ -n "${DISK_UUID:-}" ] && [ "$DISK_UUID" != "REPLACE_WITH_LSBLK_UUID" ] && device=$(blkid -U "$DISK_UUID" 2>/dev/null); then
  ok "data disk found: $device (UUID $DISK_UUID)"
  detected_type=$(blkid -s TYPE -o value "$device" 2>/dev/null || true)
  if [ "$detected_type" = "${FS_TYPE:-}" ]; then
    ok "data disk filesystem is $detected_type"
  else
    fail "data disk uses ${detected_type:-an unknown filesystem}, but FS_TYPE is ${FS_TYPE:-empty}"
  fi
else
  fail "DISK_UUID is not configured; find it with: lsblk -f"
fi

case "${SHARE_DIR:-}" in
  "$MOUNT_POINT"/*) ok "SHARE_DIR is inside the data mount" ;;
  *) fail "SHARE_DIR must be inside MOUNT_POINT" ;;
esac

if mountpoint -q "$MOUNT_POINT"; then
  ok "data disk is mounted at $MOUNT_POINT"
else
  warn "$MOUNT_POINT is not mounted yet"
fi

if docker compose version >/dev/null 2>&1; then
  ok "Docker Compose plugin is installed"
else
  fail "Docker Compose plugin is not available"
fi

if docker info >/dev/null 2>&1; then
  ok "Docker daemon is reachable"
else
  fail "Docker daemon is not reachable"
fi

if [ -c /dev/net/tun ]; then
  ok "/dev/net/tun is available for Tailscale"
else
  fail "/dev/net/tun is unavailable for Tailscale"
fi

compose_env_file=""
if [ -f "$CONFIG_FILE" ]; then
  compose_env_file=$(build_compose_env_file)
  trap 'rm -f "$compose_env_file"' EXIT
  load_env "$compose_env_file"

  for variable_name in TAILSCALE_AUTH_KEY SAMBA_USER SAMBA_PASSWORD; do
    if [[ -v $variable_name ]] && [ -n "${!variable_name}" ]; then
      ok "$variable_name is configured"
    else
      fail "$variable_name is empty in Docker service env"
    fi
  done

  if [ "${TAILSCALE_AUTH_KEY:-}" = "replace_me" ] || [ "${SAMBA_PASSWORD:-}" = "replace_me" ]; then
    fail "Docker service env still contains a service secret placeholder"
  fi
fi

if [ -f "$CONFIG_FILE" ] && docker compose \
  --project-directory "$DOCKER_DIR" \
  --env-file "$compose_env_file" \
  -f "$DOCKER_DIR/compose.yaml" \
  config --quiet >/dev/null 2>&1; then
  ok "Docker Compose configuration is valid"
else
  fail "Docker Compose configuration is invalid"
fi

echo
echo "Preflight complete: $errors error(s), $warnings warning(s)."
[ "$errors" -eq 0 ]
