#!/bin/bash

# Avoid turn off on lid close
sudo sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=ignore/' /etc/systemd/logind.conf
sudo systemctl restart systemd-logind.service

echo "Lid close behavior configured to ignore."
