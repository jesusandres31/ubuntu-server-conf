# 🐧 Ubuntu Server config for Raspberry Pi 🍓

## Find Raspberry Pi with nmap:

```sh
nmap -sn 192.168.0.1/24
nmap 192.168.0.104
```

## Setup:

### SSH:

- Create a file named "ssh" on the boot partition.

- `sudo systemctl enable ssh`

### Network and Storage scripts:

```sh
sudo sh congf/network.sh
sudo sh congf/storage.sh
```

### Docker:

[https://docs.docker.com/engine/install/ubuntu/](https://docs.docker.com/engine/install/ubuntu/)

- Execute docker containers.

### Rclone:

```sh
# todo
```

## Commands:

```sh
sudo shutdown -h now
```
