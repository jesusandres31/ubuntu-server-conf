# rclone

## Install

https://rclone.org/install/

## Config

```sh
rclone config
rclone listremotes
rclone lsf mega:sync --dirs-only
```

## Test and copy

```sh
rclone copy /mnt/ssd/smb/sync mega:sync --ignore-existing --dry-run --progress -vv
rclone copy /mnt/ssd/smb/sync mega:sync --ignore-existing --progress -vv
```

## Cron

```sh
chmod +x /home/poli/ubuntu-server-conf/conf/rclone/sync_rclone.sh
crontab -e
0 3 * * * /home/poli/ubuntu-server-conf/conf/rclone/sync_rclone.sh
```
