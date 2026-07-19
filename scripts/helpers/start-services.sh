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
COMPOSE_FILE="${COMPOSE_FILE:-$DOCKER_DIR/compose.yaml}"
compose_env_file=$(build_compose_env_file)
trap 'rm -f "$compose_env_file"' EXIT
load_env "$compose_env_file"

mountpoint -q "$MOUNT_POINT" || die "$MOUNT_POINT is not mounted; refusing to start services"
[ -d "$SHARE_DIR" ] || die "Samba directory does not exist: $SHARE_DIR"
for variable_name in TAILSCALE_AUTH_KEY SAMBA_USER SAMBA_PASSWORD; do
  if ! [[ -v $variable_name ]] || [ -z "${!variable_name}" ]; then
    die "$variable_name is empty in Docker service env"
  fi
done

if [ "${TAILSCALE_AUTH_KEY:-}" = "replace_me" ] || [ "${SAMBA_PASSWORD:-}" = "replace_me" ]; then
  die "Docker service env still contains an empty value or placeholder"
fi

docker info >/dev/null 2>&1 || die "Docker daemon is not reachable"
[ -c /dev/net/tun ] || die "/dev/net/tun is required by the Tailscale container"

docker compose \
  --project-directory "$DOCKER_DIR" \
  --env-file "$compose_env_file" \
  -f "$COMPOSE_FILE" \
  config --quiet

docker compose \
  --project-directory "$DOCKER_DIR" \
  --env-file "$compose_env_file" \
  -f "$COMPOSE_FILE" \
  up -d

docker compose \
  --project-directory "$DOCKER_DIR" \
  --env-file "$compose_env_file" \
  -f "$COMPOSE_FILE" \
  ps
