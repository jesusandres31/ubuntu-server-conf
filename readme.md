# Ubuntu Server Conf

A small provisioning repository for a single Ubuntu Server. 
Clone it on the server, fill in one `.env` file, and use one command entry point to configure the host.

It manages:

- Hostname and required Ubuntu packages
- Docker Engine and Docker Compose
- Static Netplan configuration
- Persistent data-disk mounting
- Samba, Tailscale, and Netdata containers
- A local `projects/` directory for custom application repositories

## 1. Clone

Install Git on a clean Ubuntu Server, then clone this repository:

```sh
sudo apt update
sudo apt install -y git
git clone https://github.com/jesusandres31/ubuntu-server-conf ~/ubuntu-server-conf
cd ~/ubuntu-server-conf
```

## 2. Configure

Connect the external data disk before inspecting the server hardware. 
This is the disk that will hold the NAS media and Samba share data.

Create the local configuration:

```sh
cp .env.example .env
ip link
lsblk -f
nano .env
```

Replace at least:

- `ETH_IFACE` with the Ethernet interface shown by `ip link`.
- `DISK_UUID` with the filesystem UUID shown by `lsblk -f`.
- `TAILSCALE_AUTH_KEY` with a valid reusable Tailscale auth key.
- `SAMBA_PASSWORD` with a strong password.

The data partition must already have a filesystem. 
The default configuration expects `ext4`; change `FS_TYPE` and `MOUNT_OPTIONS` when using another type.
The provisioning scripts never partition or format disks.

Keep the external disk connected before running `preflight`, `storage`, or `all`; those commands verify the UUID, update `/etc/fstab`, and mount it.

## 3. Bootstrap

Install packages, configure Docker's official Ubuntu repository, enable SSH and Docker, and set the hostname:

```sh
sudo bash scripts/provision.sh bootstrap
```

The Docker installation follows the official Ubuntu repository method from [Docker's installation guide](https://docs.docker.com/engine/install/ubuntu/).

## 4. Validate

```sh
sudo bash scripts/provision.sh preflight
```

Resolve every `[FAIL]` line. A warning that the data disk is not mounted is expected before the first provisioning run.

## 5. Apply networking

Run this once from a local keyboard and monitor. Netplan validates the file and gives you 120 seconds to confirm connectivity before rolling back:

```sh
sudo bash scripts/provision.sh network
```

Networking is deliberately excluded from `all` so a remote SSH session cannot silently apply a new static address.

## 6. Provision services

Mount storage, create the Samba directory, and start all containers:

```sh
sudo bash scripts/provision.sh all
sudo bash scripts/provision.sh status
```

Netdata is available on port `8080`. Samba publishes the `Compartido` share, and Tailscale uses host networking.

## Command reference

Use `scripts/provision.sh` as the only entry point. Files under `scripts/helpers/` are internal implementation steps called by that command.

```sh
sudo bash scripts/provision.sh bootstrap    # Install packages, SSH, Docker, hostname
sudo bash scripts/provision.sh preflight    # Validate config before changing the host
sudo bash scripts/provision.sh network      # Apply Netplan static network config
sudo bash scripts/provision.sh storage      # Add the disk to /etc/fstab and mount it
sudo bash scripts/provision.sh directories  # Create the Samba share directory
sudo bash scripts/provision.sh services     # Start Samba, Tailscale, and Netdata
sudo bash scripts/provision.sh all          # Run preflight, storage, directories, services
sudo bash scripts/provision.sh status       # Show network, mount, and container status
```

You normally do not need to run Docker Compose directly. If you want to inspect the generated Docker configuration manually:

```sh
sudo docker compose --project-directory docker --env-file .env -f docker/compose.yaml config
sudo docker compose --project-directory docker --env-file .env -f docker/compose.yaml ps
```

## Custom projects

Clone application repositories under `projects/`:

```sh
cd ~/ubuntu-server-conf/projects
git clone <application-repository-url>
```

Everything inside `projects/` is ignored by this repository, except the file that preserves the directory.

## Layout

```text
.env.example    All server configuration values
scripts/        Public provisioning entry point and internal helpers
docker/         Samba, Tailscale, and Netdata Compose services
docs/           Recovery instructions
projects/       Ignored custom application repositories
```

See [recovery](docs/recovery.md) for Netplan, storage, and Docker rollback.
