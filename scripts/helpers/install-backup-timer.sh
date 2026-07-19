#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

require_root
require_command systemctl

load_mega_backup_config

BACKUP_TIMER_ONCALENDAR="${BACKUP_TIMER_ONCALENDAR:-*-*-* 03:00:00}"
service_file="/etc/systemd/system/mega-backup.service"
timer_file="/etc/systemd/system/mega-backup.timer"

cat > "$service_file" <<EOF
[Unit]
Description=Backup NAS media to Mega
Wants=network-online.target
After=network-online.target docker.service

[Service]
Type=oneshot
WorkingDirectory=$REPO_ROOT
ExecStart=/usr/bin/bash $REPO_ROOT/scripts/provision.sh backup-run
EOF

cat > "$timer_file" <<EOF
[Unit]
Description=Run Mega NAS backup daily

[Timer]
OnCalendar=$BACKUP_TIMER_ONCALENDAR
Persistent=true

[Install]
WantedBy=timers.target
EOF

systemctl daemon-reload
systemctl enable --now mega-backup.timer

echo "Mega backup timer enabled:"
systemctl list-timers mega-backup.timer --no-pager
