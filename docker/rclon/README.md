# create rclone config file in the host

docker run -it -v ~/.config/rclone:/config/rclone rclone/rclone:beta config

sudo chmod 0644 .config/rclone/rclone.conf
