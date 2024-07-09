#!/bin/bash 
sudo timedatectl set-timezone America/Argentina/Buenos_Aires
sudo date -s "$(wget -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f5-8)Z"