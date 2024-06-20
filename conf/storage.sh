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
UUID=$(sudo blkid -s UUID -o value $PARTITION)

echo "UUID=$UUID $MOUNT_POINT exfat defaults 0 2" | sudo tee -a /etc/fstab

sudo mount -a
sudo reboot
