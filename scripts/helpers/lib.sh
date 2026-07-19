#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/../.." && pwd)
CONFIG_FILE="${CONFIG_FILE:-$REPO_ROOT/.env}"

die() {
  echo "Error: $*" >&2
  exit 1
}

require_root() {
  if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    die "run this command with sudo"
  fi
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

load_env() {
  local env_file="$1"
  [ -f "$env_file" ] || die "configuration file not found: $env_file"

  set -o allexport
  # shellcheck disable=SC1090
  source "$env_file"
  set +o allexport
}

load_config() {
  load_env "$CONFIG_FILE"
}

timestamp() {
  date +%Y%m%d-%H%M%S
}
