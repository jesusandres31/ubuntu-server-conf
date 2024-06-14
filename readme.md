# 🐧 Ubuntu Server config for Raspberry Pi 🍓

## Find Raspberry Pi with nmap:

```sh
nmap -sn 192.168.0.1/24
nmap 192.168.0.104
```

## Update the system packages and software to their latest versions:

```sh
sudo apt update
sudo apt upgrade
```

## Create user:

```sh
adduser youruser
```

And to sudoers and disable root:

```sh
usermod -aG sudo youruser
```

or

```sh
sudo useradd youruser -G sudo
sudo visudo
# add line: `youruser ALL=(ALL) NOPASSWD: ALL`
```

## Install git:

```sh
sudo apt install git
git --version
```

## Secure your server by configuring the firewall:

```sh
sudo ufw disable
sudo ufw status
sudo ufw enable
sudo ufw show added
```

### Open ports:

```sh
sudo ufw allow <PORT>/<PROTOCOL>
sudo ufw reload
```

```sh
sudo ufw allow ssh
sudo ufw allow 22/tcp

# nginx
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# wireguard
sudo ufw allow 51820/udp

# smb
sudo ufw allow 137/udp
sudo ufw allow 138/udp
sudo ufw allow 139/tcp
sudo ufw allow 445/tcp
```

## Networking:

`sudo nano /etc/netplan/50-cloud-init.yaml`

```yaml
# This file is generated from information provided by the datasource.  Changes
# to it will not persist across an instance reboot.  To disable cloud-init's
# network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0: # Change this to your interface name
      dhcp4: no
      addresses: [192.168.0.100/24]
      gateway4: 192.168.0.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
```

`sudo nano /etc/netplan/00-installer-config-wifi.yaml`

```yaml
network:
  version: 2
  renderer: networkd
  wifis:
    wlp1s0:
      dhcp4: no
      addresses: [192.168.0.100/24]
      gateway4: 192.168.0.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
      access-points:
        Fibertel WiFi206 2.4GHz:
          password: wifipassword
```

```sh
sudo netplan try # only try
sudo netplan apply
```

## Disable root and change psswd:

```sh
sudo passwd -l root

su
passwd
```

## Change default SSH port:

```sh
sudo nano /etc/ssh/sshd_config
# set: `Port <YOUR_PORT>`
sudo systemctl restart sshd
```

## Mount Disk:

```sh
sudo lsblk

mkdir /mnt/ssd

sudo blkid /dev/sdb1

sudo mount /dev/sdb1 /mnt/ssd

ls /mnt/ssd

df -h
```

### Automatic Mounting at System Startup:

```sh
# Make a backup of the fstab file:
sudo cp /etc/fstab /etc/fstab.bak

# Get the UUID of the partition:
sudo blkid /dev/sdb1

# Edit the fstab file:
UUID=1234-5678 /mnt/ssd exfat defaults 0 2 # add this line at the end of the file

# check and reboot
sudo mount -a

sudo reboot

ls /mnt/ssd
```

## Install Docker and Docker Compose:

[https://docs.docker.com/engine/install/ubuntu/](https://docs.docker.com/engine/install/ubuntu/)

## Turn off

```sh
sudo shutdown -h now
```

## Bugfixes:

- kex_exchange_identification: read: Connection reset

```
https://forums.raspberrypi.com/viewtopic.php?t=15814
remove the ssh key from the client
```

- ls: command not found

```
https://apple.stackexchange.com/questions/22859/bash-ls-command-not-found
```
