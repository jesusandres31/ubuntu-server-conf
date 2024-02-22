# Ubuntu Server Configurations

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

## Secure your server by configuring the firewall and enabling secure SSH access:

```sh
sudo ufw disable
sudo ufw status
sudo ufw enable
```

### Open ports:

```sh
sudo ufw allow <PORT>/<PROTOCOL>
sudo ufw reload
```

## Networking:

`sudo cat /etc/netplan/00-installer-config-wifi.yaml`

```yaml
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

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp2s0: # Change this to your interface name
      dhcp4: no
      addresses: [192.168.0.101/24]
      gateway4: 192.168.0.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
```

```sh
sudo netplan try
sudo netplan apply
```

## Disable root:

```sh
sudo passwd -l root
```

## install fail2ban:

```sh
sudo apt-get update && sudo apt-get install -y fail2ban
sudo systemctl start fail2ban
sudo systemctl enable fail2ban
sudo systemctl status fail2ban
sudo tail -f /var/log/fail2ban.log
```

## Avoid turn off on lid close:

````sh
sudo nano /etc/systemd/logind.conf
# set: `HandleLidSwitch=suspend -> HandleLidSwitch=ignore`
sudo systemctl restart systemd-logind.service
```sh

## Change root passwd:

```sh
su
passwd
````

## Change default SSH port:

```sh
sudo nano /etc/ssh/sshd_config
# set: `Port <YOUR_PORT>`
sudo systemctl restart sshd
```

## Install Docker and Docker Compose:

[https://docs.docker.com/engine/install/ubuntu/](https://docs.docker.com/engine/install/ubuntu/)

## Set crontab for cloudns.net:

```sh
sudo crontab -e
```

### Set cloudns.net script:

```sh
_/5 _ \* \* \* wget -P /home/youruser/cloudns.net -q --read-timeout=0.0 --waitretry=5 --tries=400 --background https://ipv4.cloudns.net/api/dynamicURL/?q=<YOUR_TOKEN>
```

#### Clean log folder:

```sh
0 */3 * * * rm -r /home/youruser/cloudns.net/* && touch /home/youruser/cloudns.net/.gitkeep
```

```sh
crontab -l
```

## Install Nginx:

[https://www.nginx.com/](https://www.nginx.com/)

## Install Certbot

[https://certbot.eff.org/](https://certbot.eff.org/)

## Setup Cloudflare DDNS:

[https://dash.cloudflare.com/](https://dash.cloudflare.com/)
