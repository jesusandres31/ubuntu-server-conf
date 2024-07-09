# 🐧 Ubuntu Server Conf

## Find Raspberry Pi with nmap:

```sh
nmap -sn 192.168.0.1/24
nmap 192.168.0.101
```

## Setup:

### SSH:

- Create a file named "ssh" on the boot partition.

- Enable ssh on start and check status:

```sh
sudo systemctl enable ssh
sudo systemctl status ssh
```

### Setup scripts:

1. Run the setup script:

```sh
sudo bash conf/setup.sh
```

1. Run the network script:

```sh
# For Raspberry Pi:
sudo bash conf/raspberry/network.sh

# For netbook:
sudo bash conf/netbook/network.sh
```

1. Run the storage script:

```sh
sudo bash config/storage.sh
```

### Install Docker:

- [https://docs.docker.com/engine/install/ubuntu/](https://docs.docker.com/engine/install/ubuntu/)

## Commands:

```sh
sudo shutdown -h now
```
