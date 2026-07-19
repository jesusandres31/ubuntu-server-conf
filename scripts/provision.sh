#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
HELPERS_DIR="$SCRIPT_DIR/helpers"

usage() {
  cat <<'EOF'
Usage: sudo bash scripts/provision.sh <command>

Commands:
  bootstrap    Install Ubuntu packages and Docker Engine
  preflight    Validate the host, configuration, disk, and Docker
  network      Apply Netplan with an interactive rollback timer
  storage      Mount the configured data disk and update /etc/fstab
  directories  Create the Samba directory on the data disk
  services     Validate and start the Docker Compose services
  all          Run preflight, storage, directories, and services
  status       Show network, storage, and container status

The all command deliberately excludes network. Run network from a local console
after checking the server interface name.
EOF
}

command_name="${1:-help}"

case "$command_name" in
  bootstrap)
    exec bash "$HELPERS_DIR/install-dependencies.sh"
    ;;
  preflight)
    exec bash "$HELPERS_DIR/preflight.sh"
    ;;
  network)
    exec bash "$HELPERS_DIR/apply-network.sh"
    ;;
  storage)
    exec bash "$HELPERS_DIR/apply-storage.sh"
    ;;
  directories)
    exec bash "$HELPERS_DIR/prepare-directories.sh"
    ;;
  services)
    exec bash "$HELPERS_DIR/start-services.sh"
    ;;
  all)
    bash "$HELPERS_DIR/preflight.sh"
    bash "$HELPERS_DIR/apply-storage.sh"
    bash "$HELPERS_DIR/prepare-directories.sh"
    bash "$HELPERS_DIR/start-services.sh"
    ;;
  status)
    exec bash "$HELPERS_DIR/status.sh"
    ;;
  help|-h|--help)
    usage
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac
