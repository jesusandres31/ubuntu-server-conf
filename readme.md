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

1. Run the network script first:

- For Raspberry Pi:

```sh
sudo bash conf/raspberry/network.sh
```

- For netbook:

```sh
sudo bash conf/netbook/network.sh
```

2. Run the lid script for netbook (if applicable):

```sh
sudo bash conf/netbook/lid.sh
```

3. Run the storage script:

```sh
sudo bash config/storage.sh
```

### Docker:

- Install Docker: [https://docs.docker.com/engine/install/ubuntu/](https://docs.docker.com/engine/install/ubuntu/)

- Execute Docker containers.

## Commands:

```sh
sudo shutdown -h now
```
