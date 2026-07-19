#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

require_root
require_command mountpoint

load_config

MOUNT_POINT="${MOUNT_POINT:-/mnt/ssd}"
SHARE_DIR="${SHARE_DIR:-$MOUNT_POINT/smb}"
SERVER_USER="${SERVER_USER:-}"

mountpoint -q "$MOUNT_POINT" || die "$MOUNT_POINT is not mounted; refusing to create data directories on the root disk"
[ -n "$SERVER_USER" ] || die "SERVER_USER must be set in $CONFIG_FILE"
id "$SERVER_USER" >/dev/null 2>&1 || die "server user does not exist: $SERVER_USER"

case "${FS_TYPE:-}" in
  exfat|vfat|ntfs|ntfs3)
    mkdir -p "$SHARE_DIR"
    ;;
  *)
    install -d -m 0775 -o "$SERVER_USER" -g "$SERVER_USER" "$SHARE_DIR"
    ;;
esac

echo "Data directories ready:"
printf '  %s\n' "$SHARE_DIR"
