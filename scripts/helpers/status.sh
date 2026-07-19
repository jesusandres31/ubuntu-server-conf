#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"
load_config

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
    --project-directory "$REPO_ROOT/docker" \
    --env-file "$CONFIG_FILE" \
    -f "$REPO_ROOT/docker/compose.yaml" \
    ps
else
  echo "$CONFIG_FILE is not configured"
fi
