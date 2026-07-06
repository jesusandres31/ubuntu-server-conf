#!/bin/bash
set -euo pipefail

rclone copy /mnt/ssd/smb/sync mega:sync --ignore-existing --progress -vv
