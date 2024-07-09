#!/bin/bash

# Mount Disk
echo "Mounting disk..."
sudo lsblk

PARTITION="/dev/sdb1"
MOUNT_POINT="/mnt/ssd"
sudo mkdir -p $MOUNT_POINT
sudo mount $PARTITION $MOUNT_POINT
ls $MOUNT_POINT
df -h

# Automatic Mounting at System Startup
echo "Configuring automatic mounting at startup..."
sudo cp /etc/fstab /etc/fstab.bak
sudo sed -i "\|$PARTITION|d" /etc/fstab
echo "$PARTITION $MOUNT_POINT exfat defaults,fmask=0000,dmask=0000 0 0" | sudo tee -a /etc/fstab

cat /etc/fstab

echo "done..."

sudo mount -a
sudo reboot now