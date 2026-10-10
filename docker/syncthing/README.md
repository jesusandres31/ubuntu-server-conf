# Syncthing

Syncs the Obsidian vault between the server and personal computers. The vault
lives at `SYNCTHING_VAULT_DIR` (default `/mnt/ssd/smb/obsidian`) and is mounted
in the container at `/vault`. To change the UID, GID, or vault path, copy
`.env.example` to `.env` and edit it.

## Start

```sh
sudo bash scripts/provision.sh all
# or, on an already provisioned server:
sudo bash scripts/provision.sh directories
sudo bash scripts/provision.sh services
```

## Open the web interface

The GUI only listens on the server's localhost. Tunnel to it over Tailscale
(local port 8385, so it doesn't clash with a local Syncthing on 8384):

```sh
ssh -L 8385:127.0.0.1:8384 ltc@thinkcenter
```

Browse to <http://127.0.0.1:8385> and set a GUI username and password in
**Actions > Settings > GUI**.

## Create the vault folder (server)

**Add Folder** with:

- **General**: Label `Obsidian`, ID `obsidian-vault`, Path `/vault`
  (the container path, not `/mnt/ssd/smb/obsidian`). Type: Send & Receive.
- **File Versioning**: Staggered, so the server keeps old versions of edited
  or deleted notes.
- **Sharing**: leave empty until the computers are paired.

## Pair a Windows computer

1. Install and start Syncthing (start it from a new shell so the PATH is
   updated). Its GUI opens at <http://127.0.0.1:8384>:

   ```powershell
   winget install Syncthing.Syncthing
   syncthing
   ```

2. Copy the computer's ID from **Actions > Show ID**, then add it on the
   server (<http://127.0.0.1:8385>) with **Add Remote Device**.
3. On the computer, accept the `thinkcenter-syncthing` device and set
   **Addresses** to `tcp://thinkcenter:22000` so it connects over Tailscale.
4. On the server, edit the `Obsidian` folder and share it with the device.
5. On the computer, accept the folder, pick the local vault directory, and
   open it in Obsidian.

The winget package does not start with Windows; see [win/](win/README.md) to
start it at logon.

Syncthing propagates deletions; versioning helps but is not a backup.
