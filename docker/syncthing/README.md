# Syncthing

Syncthing keeps the Obsidian vault on the server synchronized with your personal
computers. Its server-side directory is set by `SYNCTHING_VAULT_DIR` in
`.env.example` (by default, `/mnt/ssd/smb/obsidian`) and is mounted in the
container at `/vault`.

To customize the UID, GID, or vault location, copy the defaults and edit them:

```sh
cp docker/syncthing/.env.example docker/syncthing/.env
nano docker/syncthing/.env
```

## Start the service

The normal `all` provisioning command creates the server-side directory and
starts Syncthing with the other Docker services:

```sh
sudo bash scripts/provision.sh all
```

If the server is already provisioned, run the directory and service steps:

```sh
sudo bash scripts/provision.sh directories
sudo bash scripts/provision.sh services
```

## Open the web interface

The web interface is bound to localhost on the server. From a personal computer,
open an SSH tunnel through Tailscale:

```sh
ssh -L 8384:127.0.0.1:8384 ltc@thinkcenter
```

Then browse to <http://127.0.0.1:8384>. Set a GUI username and password in
**Actions > Settings > GUI** before using it.

## Pair devices and add the vault

1. Open the server's Syncthing web interface and add each personal computer as a
   remote device. Confirm the device on the other computer.
2. On each computer, edit the `thinkcenter` device and set **Addresses** to
   `tcp://thinkcenter:22000`. This directs its connection to the server through
   Tailscale instead of relying on Syncthing's public discovery or relay path.
3. On the server, add a folder with path `/vault` and share it with those devices.
   Syncthing will keep the same folder ID when each device accepts the share.
4. On each computer, accept the shared folder and choose that computer's local
   Obsidian vault directory as its folder path.
5. In Obsidian on each computer, open that local vault directory.
6. Enable file versioning for the server's `/vault` folder in Syncthing so
   overwritten or deleted notes can be recovered there.

Syncthing propagates deletions, so file versioning is useful but does not replace
an independent backup.
