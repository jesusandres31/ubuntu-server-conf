#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

require_root
require_command blkid
require_command findmnt
require_command mountpoint

load_config

PARTITION="${PARTITION:-}"
DISK_UUID="${DISK_UUID:-}"
DISK_LABEL="${DISK_LABEL:-}"
MOUNT_POINT="${MOUNT_POINT:-/mnt/ssd}"
FS_TYPE="${FS_TYPE:-ext4}"
MOUNT_OPTIONS="${MOUNT_OPTIONS:-defaults,nofail}"

if [ -n "$DISK_UUID" ]; then
  [ "$DISK_UUID" != "REPLACE_WITH_LSBLK_UUID" ] || die "replace DISK_UUID in $CONFIG_FILE; find it with: lsblk -f"
  device=$(blkid -U "$DISK_UUID" || true)
  [ -n "$device" ] || die "no block device found with UUID $DISK_UUID"
  SOURCE="UUID=$DISK_UUID"
elif [ -n "$DISK_LABEL" ]; then
  device=$(blkid -L "$DISK_LABEL" || true)
  [ -n "$device" ] || die "no block device found with label $DISK_LABEL"
  SOURCE="LABEL=$DISK_LABEL"
elif [ -n "$PARTITION" ]; then
  [ -b "$PARTITION" ] || die "block device does not exist: $PARTITION"
  device="$PARTITION"
  SOURCE="$PARTITION"
else
  die "set DISK_UUID, DISK_LABEL, or PARTITION in $CONFIG_FILE"
fi

detected_type=$(blkid -s TYPE -o value "$device")
[ "$detected_type" = "$FS_TYPE" ] || die "expected $FS_TYPE on $device, found ${detected_type:-unknown}"

mkdir -p "$MOUNT_POINT"
if mountpoint -q "$MOUNT_POINT"; then
  expected_device=$(readlink -f "$device")
  mounted_device=$(findmnt -n -o SOURCE --target "$MOUNT_POINT")
  mounted_device=$(readlink -f "$mounted_device")
  if [ "$mounted_device" != "$expected_device" ]; then
    die "$MOUNT_POINT is already mounted from a different disk"
  fi
else
  echo "Mounting $SOURCE on $MOUNT_POINT"
  mount -t "$FS_TYPE" "$SOURCE" "$MOUNT_POINT"
fi

fstab_backup="/etc/fstab.bak.$(timestamp)"
cp -a /etc/fstab "$fstab_backup"
fstab_tmp=$(mktemp)
trap 'rm -f "$fstab_tmp"' EXIT
awk -v target="$MOUNT_POINT" '$2 != target' /etc/fstab > "$fstab_tmp"
printf '%s %s %s %s 0 0\n' "$SOURCE" "$MOUNT_POINT" "$FS_TYPE" "$MOUNT_OPTIONS" >> "$fstab_tmp"
install -m 644 "$fstab_tmp" /etc/fstab

mount -a
mountpoint -q "$MOUNT_POINT" || die "$MOUNT_POINT is not mounted after updating /etc/fstab"
echo "Storage ready: $(findmnt -n -o SOURCE,FSTYPE,TARGET --target "$MOUNT_POINT")"
echo "Backed up /etc/fstab to $fstab_backup"
