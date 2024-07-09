#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# Path to the .env file
ENV_FILE="$SCRIPT_DIR/.env"

# Load environment variables from the .env file
if [ ! -f "$ENV_FILE" ]; then
  echo "Error: .env file not found in $SCRIPT_DIR."
  exit 1
fi

export $(grep -v '^#' "$ENV_FILE" | xargs)

# Ensure the RASPI environment variables are set
if [ -z "$RASPI" ]; then
  echo "Error: RASPI environment variables must be set."
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

if [ -z "$RASPI" ]; then
    echo "RASPI variable not set in .env file."
    exit 1
fi

IP_ADDRESS="192.168.0.10${RASPI}/24"

echo "Configuring networking..."
sudo bash -c "cat > $NETPLAN_CONFIG" <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: no
      addresses: [${IP_ADDRESS}]
      gateway4: 192.168.0.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
EOF

cat /etc/netplan/50-cloud-init.yaml
echo "Networking configuration updated."

sudo bash -c "cat > $CLOUD_CFG" <<EOF
network: { config: disabled }
EOF

cat /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
echo "cloud.cfg.d configuration updated."

cat /etc/netplan/00-installer-config-wifi.yaml
echo "Wifi configuration updated."

sudo netplan apply
