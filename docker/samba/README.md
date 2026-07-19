# Samba

This service publishes the configured `SHARE_DIR` as:

```text
\\192.168.0.101\Compartido
```

Default credentials are defined in `.env.example`:

```text
thinkcenter / thinkcenter
```

To customize them, create a local env file:

```sh
cp docker/samba/.env.example docker/samba/.env
nano docker/samba/.env
sudo bash scripts/provision.sh services
```

## Windows Cached Credentials

If Windows has cached SMB credentials for this IP, it may reject the new share.

From PowerShell:

```powershell
net use \\192.168.0.101\Compartido /delete
cmdkey /list
cmdkey /delete:192.168.0.101
net use \\192.168.0.101\Compartido /user:thinkcenter thinkcenter
```

Then open:

```text
\\192.168.0.101\Compartido
```
