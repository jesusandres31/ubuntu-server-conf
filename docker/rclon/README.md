# install

https://rclone.org/install/

# config

rclone config

ls ~/.config/rclone/rclone.conf

rclone listremotes

rclone lsf mega:MEGASync --dirs-only

# sync

test:
rclone sync --dry-run /mnt/ssd/smb/MEGASync mega:MEGASync

sync:
rclone sync /mnt/ssd/smb/MEGASync mega:MEGASync
