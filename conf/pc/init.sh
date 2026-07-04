#!/bin/bash 

# Setup timezone
sudo timedatectl set-timezone America/Argentina/Buenos_Aires
sudo date -s "$(wget -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f5-8)Z"

# Avoid turn off on lid close
sudo sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=ignore/' /etc/systemd/logind.conf
sudo systemctl restart systemd-logind.service 
echo "Lid close behavior configured to ignore."
