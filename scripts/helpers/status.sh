#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"
load_config
compose_env_file=$(build_compose_env_file)
trap 'rm -f "$compose_env_file"' EXIT

MOUNT_POINT="${MOUNT_POINT:-/mnt/ssd}"

echo "Host: $(hostname)"
echo
echo "Addresses:"
ip -brief address
echo
echo "Storage:"
findmnt "$MOUNT_POINT" || true
echo
echo "Docker services:"
if [ -f "$CONFIG_FILE" ]; then
  docker compose \
    --project-directory "$DOCKER_DIR" \
    --env-file "$compose_env_file" \
    -f "$DOCKER_DIR/compose.yaml" \
    ps
else
  echo "$CONFIG_FILE is not configured"
fi
