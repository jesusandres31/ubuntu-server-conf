# Ubuntu Server Configurations

## Update the system packages and software to their latest versions:

```
sudo apt update
sudo apt upgrade
```

<hr/>

## Secure your server by configuring the firewall and enabling secure SSH access:

```
sudo ufw disable
sudo ufw status
sudo ufw enable
```

<hr/>

## Install git:

```
sudo apt install git
git --version
```

<hr/>

## Install Docker and Docker Compose:

[https://docs.docker.com/engine/install/ubuntu/](https://docs.docker.com/engine/install/ubuntu/)

<hr/>

## Networking:

`sudo cat /etc/netplan/00-installer-config-wifi.yaml`

```
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
        Fibertel WiFi206 2.4GHz:
          password: wifipassword
```

`sudo cat /etc/netplan/00-installer-config.yaml`

```
network:
  version: 2
  renderer: networkd
  ethernets:
    enp2s0:  # Change this to your interface name
      dhcp4: no
      addresses: [192.168.0.101/24]
      gateway4: 192.168.0.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
```

- sudo netplan try

- sudo netplan apply

<hr/>

## Add user to sudoers and disable root:

- sudo useradd poli -G sudo
- sudo visudo
- add line: `poli ALL=(ALL) NOPASSWD: ALL`

<hr/>

## Disable root:

- sudo passwd -l root

<hr/>

## install fail2ban:

- sudo apt-get update && sudo apt-get install -y \
  fail2ban
- sudo systemctl start fail2ban
- sudo systemctl enable fail2ban
- sudo systemctl status fail2ban
- sudo tail -f /var/log/fail2ban.log

<hr/>

## Avoid turn off on lid close:

- sudo nano /etc/systemd/logind.conf
- set: `HandleLidSwitch=suspend -> HandleLidSwitch=ignore`
- sudo systemctl restart systemd-logind.service

<hr/>

## Change root passwd:

```
su
passwd
```

<hr/>

## Change default SSH port:

- sudo nano /etc/ssh/sshd_config
- set: `Port <YOUR_PORT>`
- sudo systemctl restart sshd

<hr/>

## Set crontab for cloudns.net:

- sudo crontab -e

### Set cloudns.net script:

```
_/5 _ \* \* \* wget -P /home/poli/cloudns.net -q --read-timeout=0.0 --waitretry=5 --tries=400 --background https://ipv4.cloudns.net/api/dynamicURL/?q=<YOUR_TOKEN>
```

### Clean log folder:

```
0 */3 * * * rm -r /home/poli/cloudns.net/* && touch /home/poli/cloudns.net/.gitkeep

```

- crontab -l

<hr/>
