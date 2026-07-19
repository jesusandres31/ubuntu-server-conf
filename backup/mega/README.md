# Mega Backup

This backs up NAS media data from the external disk to Mega using `rclone`.

The backup source and destination are configured in `.env.example`:

```text
BACKUP_SOURCE_DIR=/mnt/ssd/smb/sync
BACKUP_REMOTE=mega:sync
BACKUP_IGNORE_EXISTING=true
BACKUP_TIMER_ONCALENDAR="*-*-* 03:00:00"
```

The real Mega credentials are not stored in this repository. Configure rclone
as the server user, without `sudo`:

```sh
rclone config
rclone listremotes
```

Create a remote named:

```text
mega
```

If `Storage> mega` fails with `didn't find backend called "mega"`, quit the interactive prompt with `q` and install the official rclone binary:

```sh
sudo bash scripts/provision.sh bootstrap
rclone help backends | grep mega
```

Then run `rclone config` again.

The interactive flow should be:

```text
n) New remote
name> mega
Storage> mega
user> your-mega-email@example.com
y/g/n> y
password> your Mega password
y/e/d> y
```

If the Mega account has 2FA enabled, rclone may also ask for the current 2FA
code. The Mega account must have been logged into at least once in a browser so
Mega has generated its account encryption keys.

After configuration, verify that the remote exists:

```sh
rclone listremotes
rclone lsd mega:
```

Then validate and test:

```sh
sudo bash scripts/provision.sh backup-check
sudo bash scripts/provision.sh backup-dry-run
```

Run the backup:

```sh
sudo bash scripts/provision.sh backup-run
```

By default this uses `rclone copy` with `--ignore-existing`, so files already
present in Mega are not overwritten.

Enable the daily timer:

```sh
sudo bash scripts/provision.sh backup-timer
systemctl list-timers mega-backup.timer
```
