#!/bin/bash

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Update the system packages and software to their latest versions
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Enable ssh
echo "Enabling SSH..."
sudo systemctl enable ssh
sudo systemctl start ssh

# Create a file named "ssh" on the boot partition
BOOT_PARTITION=$(lsblk -o MOUNTPOINT,UUID | grep boot | awk '{print $1}')
if [ -z "$BOOT_PARTITION" ]; then
    echo "Boot partition not found. Please create the 'ssh' file manually."
else
    echo "Creating 'ssh' file on boot partition..."
    sudo touch ${BOOT_PARTITION}/ssh
fi

# Networking configuration
NETPLAN_CONFIG="/etc/netplan/50-cloud-init.yaml"
CLOUD_CFG="/etc/cloud/cloud.cfg.d/99-disable-network-config.cfg"

echo "Configuring networking..."
sudo bash -c "cat > $NETPLAN_CONFIG" <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: no
      addresses: [192.168.0.104/24]
      gateway4: 192.168.0.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
EOF

sudo bash -c "cat > $CLOUD_CFG" <<EOF
network: { config: disabled }
EOF

sudo netplan apply
