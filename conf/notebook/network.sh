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

# Source the .env file to load environment variables
set -o allexport
source "$ENV_FILE"
set +o allexport

# Ensure the WIFI_PASSWORD and WIFI_NETWORK environment variables are set
if [ -z "$WIFI_PASSWORD" ] || [ -z "$WIFI_NETWORK" ]; then
  echo "Error: WIFI_PASSWORD and WIFI_NETWORK environment variables must be set."
  exit 1
fi

# Backup existing netplan configurations
sudo cp /etc/netplan/00-installer-config-wifi.yaml /etc/netplan/00-installer-config-wifi.yaml.bak
sudo cp /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bak

# Configure WiFi
sudo tee /etc/netplan/00-installer-config-wifi.yaml > /dev/null <<EOL
network:
  version: 2
  renderer: networkd
  wifis:
    wlp1s0:
      dhcp4: no
      addresses: [192.168.0.102/24]
      gateway4: 192.168.0.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
      access-points:
        "$WIFI_NETWORK":
          password: "$WIFI_PASSWORD"
EOL

cat /etc/netplan/00-installer-config-wifi.yaml
echo "Wifi configuration updated."

# Configure Ethernet
sudo tee /etc/netplan/00-installer-config.yaml > /dev/null <<EOL
network:
  version: 2
  renderer: networkd
  ethernets:
    enp2s0:
      dhcp4: no
      addresses: [192.168.0.101/24]
      gateway4: 192.168.0.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
EOL

cat /etc/netplan/00-installer-config.yaml
echo "Ethernet configuration updated."

sudo netplan apply 