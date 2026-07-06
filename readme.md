# Ubuntu Server Conf

## Find Raspberry Pi

```sh
nmap -sn 192.168.0.1/24
nmap 192.168.0.101
```

## Setup

### Raspberry Pi

```sh
cp conf/rpi/example.env conf/rpi/.env
nano conf/rpi/.env
sudo bash conf/rpi/network.sh
```

### Storage

```sh
lsblk -f
sudo DISK_UUID=<uuid> bash conf/storage.sh
```

### Docker services

```sh
cd docker/tailscale
cp example.env .env
nano .env
docker compose up -d

cd ../samba
cp example.env .env
nano .env
docker compose up -d
```

### SSH

```sh
sudo systemctl enable ssh
sudo systemctl status ssh
```

### Docker install

- [https://docs.docker.com/engine/install/ubuntu/](https://docs.docker.com/engine/install/ubuntu/)

## Commands

```sh
sudo shutdown -h now
```
