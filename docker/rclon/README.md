# install

https://rclone.org/install/

# config

```sh
rclone config

ls ~/.config/rclone/rclone.conf

rclone listremotes

rclone lsf mega:sync --dirs-only

rclone ls mega: --max-depth 1

# test
rclone copy /mnt/ssd/smb/sync mega:sync --ignore-existing --dry-run --progress -vv

# copy
rclone copy /mnt/ssd/smb/sync mega:sync --ignore-existing --progress -vv
```

# crontab

```sh
chmod +x sync_rclone.sh

crontab -e

0 3 * * * /home/poli/ubuntu-server-conf/docker/rclon/sync_rclone.sh

crontab -l
```
