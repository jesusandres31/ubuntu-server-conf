#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

require_root
require_command ip
require_command netplan

load_config

ETH_IFACE="${ETH_IFACE:-}"
ETH_ADDRESS="${ETH_ADDRESS:-192.168.0.101/24}"
GATEWAY="${GATEWAY:-192.168.0.1}"
DNS="${DNS:-1.1.1.1, 8.8.8.8}"
NETPLAN_CONFIG="${NETPLAN_CONFIG:-/etc/netplan/01-netcfg.yaml}"

[ -n "$ETH_IFACE" ] || die "ETH_IFACE must be set in $CONFIG_FILE"
[ "$ETH_IFACE" != "REPLACE_WITH_INTERFACE" ] || die "replace ETH_IFACE in $CONFIG_FILE; find it with: ip link"
[[ "$ETH_IFACE" =~ ^[a-zA-Z0-9_.:-]+$ ]] || die "invalid interface name: $ETH_IFACE"
ip link show "$ETH_IFACE" >/dev/null 2>&1 || die "interface does not exist: $ETH_IFACE"

if [ -n "${WIFI_IFACE:-}" ]; then
  [[ "$WIFI_IFACE" =~ ^[a-zA-Z0-9_.:-]+$ ]] || die "invalid Wi-Fi interface name: $WIFI_IFACE"
  ip link show "$WIFI_IFACE" >/dev/null 2>&1 || die "interface does not exist: $WIFI_IFACE"
fi

if [ -n "${WIFI_IFACE:-}" ] || [ -n "${WIFI_NETWORK:-}" ] || [ -n "${WIFI_PASSWORD:-}" ]; then
  [ -n "${WIFI_IFACE:-}" ] || die "WIFI_IFACE is required when Wi-Fi is configured"
  [ -n "${WIFI_NETWORK:-}" ] || die "WIFI_NETWORK is required when Wi-Fi is configured"
  [ -n "${WIFI_PASSWORD:-}" ] || die "WIFI_PASSWORD is required when Wi-Fi is configured"
fi

escape_yaml_double_quote() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  printf '%s' "$value"
}

backup_file=""
if [ -f "$NETPLAN_CONFIG" ]; then
  backup_file="$NETPLAN_CONFIG.bak.$(timestamp)"
  cp -a "$NETPLAN_CONFIG" "$backup_file"
  echo "Backed up $NETPLAN_CONFIG to $backup_file"
fi

cat > "$NETPLAN_CONFIG" <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    $ETH_IFACE:
      dhcp4: false
      dhcp6: false
      accept-ra: false
      addresses:
        - $ETH_ADDRESS
      routes:
        - to: default
          via: $GATEWAY
      nameservers:
        addresses: [$DNS]
EOF

if [ -n "${WIFI_IFACE:-}" ]; then
  wifi_network=$(escape_yaml_double_quote "$WIFI_NETWORK")
  wifi_password=$(escape_yaml_double_quote "$WIFI_PASSWORD")
  cat >> "$NETPLAN_CONFIG" <<EOF
  wifis:
    $WIFI_IFACE:
      dhcp4: false
      dhcp6: false
      accept-ra: false
      addresses:
        - ${WIFI_ADDRESS:-192.168.0.102/24}
      nameservers:
        addresses: [$DNS]
      access-points:
        "$wifi_network":
          password: "$wifi_password"
      optional: true
EOF
fi

chmod 600 "$NETPLAN_CONFIG"

if ! netplan generate; then
  if [ -n "$backup_file" ]; then
    cp -a "$backup_file" "$NETPLAN_CONFIG"
  else
    rm -f "$NETPLAN_CONFIG"
  fi
  die "Netplan validation failed; the previous configuration was restored"
fi

echo "Netplan is valid. Confirm the connection when prompted; otherwise it will roll back."
netplan try --timeout 120
