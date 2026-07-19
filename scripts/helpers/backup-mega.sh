#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

require_root
require_command awk
require_command findmnt
require_command getent
require_command grep
require_command mountpoint
require_command rclone
require_command runuser

mode="${1:-check}"
load_mega_backup_config

MOUNT_POINT="${MOUNT_POINT:-/mnt/ssd}"
BACKUP_SOURCE_DIR="${BACKUP_SOURCE_DIR:-$MOUNT_POINT/smb/sync}"
BACKUP_REMOTE="${BACKUP_REMOTE:-mega:sync}"
BACKUP_IGNORE_EXISTING="${BACKUP_IGNORE_EXISTING:-true}"
SERVER_USER="${SERVER_USER:-}"

[ -n "$SERVER_USER" ] || die "SERVER_USER must be set in $CONFIG_FILE"
id "$SERVER_USER" >/dev/null 2>&1 || die "server user does not exist: $SERVER_USER"
mountpoint -q "$MOUNT_POINT" || die "$MOUNT_POINT is not mounted"
[ -d "$BACKUP_SOURCE_DIR" ] || die "backup source directory does not exist: $BACKUP_SOURCE_DIR"

user_home=$(getent passwd "$SERVER_USER" | awk -F: '{print $6}')
[ -n "$user_home" ] || die "could not determine home directory for $SERVER_USER"

run_as_server_user() {
  runuser -u "$SERVER_USER" -- env HOME="$user_home" "$@"
}

remote_name="${BACKUP_REMOTE%%:*}:"
if ! run_as_server_user rclone listremotes | grep -Fx "$remote_name" >/dev/null 2>&1; then
  die "rclone remote not found for $SERVER_USER: $remote_name. Run: rclone config"
fi

echo "Mega backup configuration:"
printf '  user:   %s\n' "$SERVER_USER"
printf '  source: %s\n' "$BACKUP_SOURCE_DIR"
printf '  remote: %s\n' "$BACKUP_REMOTE"

case "$mode" in
  check)
    echo "Backup check complete."
    ;;
  dry-run|run)
    args=(copy "$BACKUP_SOURCE_DIR" "$BACKUP_REMOTE" --progress -vv)
    if [ "$BACKUP_IGNORE_EXISTING" = "true" ]; then
      args+=(--ignore-existing)
    fi
    if [ "$mode" = "dry-run" ]; then
      args+=(--dry-run)
    fi
    run_as_server_user rclone "${args[@]}"
    ;;
  *)
    die "unknown backup mode: $mode"
    ;;
esac
