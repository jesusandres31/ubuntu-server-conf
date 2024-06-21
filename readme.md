# 🐧 Ubuntu Server config for Raspberry Pi 🍓

## Find Raspberry Pi with nmap:

```sh
nmap -sn 192.168.0.1/24
nmap 192.168.0.104
```

## Setup:

### SSH:

- Create a file named "ssh" on the boot partition.

- Enable ssh on start: `sudo systemctl enable ssh`

- Check status: `sudo systemctl status ssh`

### Setup scripts:

- Run the network script first: `sudo sh congf/network.sh`

- Run the storage script then: `sudo sh congf/storage.sh`

### Docker:

- Install Docker: [https://docs.docker.com/engine/install/ubuntu/](https://docs.docker.com/engine/install/ubuntu/)

- Execute docker containers.

### Rclone:

- todo

## Commands:

```sh
sudo shutdown -h now
```
