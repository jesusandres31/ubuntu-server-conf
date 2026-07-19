# Recovery

Use a keyboard and monitor for network recovery. Do not edit or format the data
disk while diagnosing a mount problem.

## Network rollback

The network script creates timestamped backups beside
`/etc/netplan/01-netcfg.yaml` before replacing it. List them and restore the
newest known-good file:

```sh
sudo ls -lt /etc/netplan/01-netcfg.yaml*
sudo cp /etc/netplan/01-netcfg.yaml.bak.YYYYMMDD-HHMMSS /etc/netplan/01-netcfg.yaml
sudo netplan generate
sudo netplan apply
```

If the interface name changed, inspect it with `ip link`, correct
`ETH_IFACE` in `.env`, and run the network command again locally.

## Storage rollback

The storage script creates `/etc/fstab.bak.YYYYMMDD-HHMMSS`. If boot enters
emergency mode or mounting fails:

```sh
lsblk -f
sudo cp /etc/fstab.bak.YYYYMMDD-HHMMSS /etc/fstab
sudo mount -a
findmnt /mnt/ssd
```

The `nofail` option should allow Ubuntu to boot when the external disk is absent.
Docker services should remain stopped until `/mnt/ssd` is mounted.

## Docker services

```sh
cd ~/ubuntu-server-conf
docker compose --project-directory docker --env-file .env -f docker/compose.yaml ps
docker compose --project-directory docker --env-file .env -f docker/compose.yaml logs --tail=100
sudo bash scripts/provision.sh services
```

Do not use `docker compose down -v` during routine recovery because it also
removes named volumes.
