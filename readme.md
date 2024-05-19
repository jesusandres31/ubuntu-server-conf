# My Ubuntu Server config for Raspberry Pi 🐧🖥🍓

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
      addresses: [192.168.0.100/24]
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
      addresses: [192.168.0.100/24]
      gateway4: 192.168.0.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
```

```sh
sudo netplan try
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

## Install Docker and Docker Compose:

[https://docs.docker.com/engine/install/ubuntu/](https://docs.docker.com/engine/install/ubuntu/)
