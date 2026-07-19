#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

require_root
require_command docker
require_command mountpoint

load_config

MOUNT_POINT="${MOUNT_POINT:-/mnt/ssd}"
SHARE_DIR="${SHARE_DIR:-$MOUNT_POINT/smb}"
COMPOSE_FILE="${COMPOSE_FILE:-$REPO_ROOT/docker/compose.yaml}"

mountpoint -q "$MOUNT_POINT" || die "$MOUNT_POINT is not mounted; refusing to start services"
[ -d "$SHARE_DIR" ] || die "Samba directory does not exist: $SHARE_DIR"
if grep -Eq '^(TAILSCALE_AUTH_KEY|SAMBA_PASSWORD)=(|key|change_me|replace_me)$' "$CONFIG_FILE"; then
  die "$CONFIG_FILE still contains an empty value or placeholder"
fi

docker info >/dev/null 2>&1 || die "Docker daemon is not reachable"
[ -c /dev/net/tun ] || die "/dev/net/tun is required by the Tailscale container"

docker compose \
  --project-directory "$REPO_ROOT/docker" \
  --env-file "$CONFIG_FILE" \
  -f "$COMPOSE_FILE" \
  config --quiet

docker compose \
  --project-directory "$REPO_ROOT/docker" \
  --env-file "$CONFIG_FILE" \
  -f "$COMPOSE_FILE" \
  up -d

docker compose \
  --project-directory "$REPO_ROOT/docker" \
  --env-file "$CONFIG_FILE" \
  -f "$COMPOSE_FILE" \
  ps
