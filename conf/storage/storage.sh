#!/bin/bash
set -euo pipefail

PARTITION="${PARTITION:-}"
DISK_UUID="${DISK_UUID:-}"
DISK_LABEL="${DISK_LABEL:-}"
MOUNT_POINT="${MOUNT_POINT:-/mnt/ssd}"
FS_TYPE="${FS_TYPE:-exfat}"

if [ -n "$DISK_UUID" ]; then
  SOURCE="UUID=$DISK_UUID"
elif [ -n "$DISK_LABEL" ]; then
  SOURCE="LABEL=$DISK_LABEL"
elif [ -n "$PARTITION" ]; then
  SOURCE="$PARTITION"
else
  echo "Set DISK_UUID, DISK_LABEL or PARTITION. Example:"
  echo "sudo DISK_UUID=<uuid> bash conf/storage.sh"
  lsblk -f
  exit 1
fi

echo "Mounting $SOURCE on $MOUNT_POINT..."
sudo mkdir -p "$MOUNT_POINT"
if ! mountpoint -q "$MOUNT_POINT"; then
  sudo mount "$SOURCE" "$MOUNT_POINT"
fi
df -h

echo "Configuring /etc/fstab..."
sudo cp /etc/fstab /etc/fstab.bak
sudo sed -i "\|[[:space:]]$MOUNT_POINT[[:space:]]|d" /etc/fstab
echo "$SOURCE $MOUNT_POINT $FS_TYPE defaults,nofail,fmask=0000,dmask=0000 0 0" | sudo tee -a /etc/fstab

sudo mount -a
echo "Done."
