#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/../.." && pwd)
CONFIG_FILE="${CONFIG_FILE:-$REPO_ROOT/.env}"
DOCKER_DIR="$REPO_ROOT/docker"

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

append_env_file() {
  local source_file="$1"
  local target_file="$2"

  if [ -f "$source_file" ]; then
    {
      printf '\n'
      cat "$source_file"
    } >> "$target_file"
  fi
}

build_compose_env_file() {
  local compose_env_file
  compose_env_file=$(mktemp)

  append_env_file "$CONFIG_FILE" "$compose_env_file"
  append_env_file "$DOCKER_DIR/tailscale/.env.example" "$compose_env_file"
  append_env_file "$DOCKER_DIR/tailscale/.env" "$compose_env_file"
  append_env_file "$DOCKER_DIR/samba/.env.example" "$compose_env_file"
  append_env_file "$DOCKER_DIR/samba/.env" "$compose_env_file"
  append_env_file "$DOCKER_DIR/netdata/.env.example" "$compose_env_file"
  append_env_file "$DOCKER_DIR/netdata/.env" "$compose_env_file"

  printf '%s\n' "$compose_env_file"
}

timestamp() {
  date +%Y%m%d-%H%M%S
}
