#!/usr/bin/env bash

#############################################
# System Checks Library
# Low level reusable system validations
#############################################

check_root() {

  if [ "$EUID" -eq 0 ]; then
      error "Do not run this script as root."
      exit 1
  fi

}

check_command() {

  local cmd="$1"

  if ! command -v "$cmd" &>/dev/null; then
      error "Required command not found: $cmd"
      exit 1
  fi

}

check_service_running() {

  local service="$1"

  if systemctl is-active --quiet "$service"; then
      ok "$service service running"
  else
      warn "$service service not running"
  fi

}

check_port_in_use() {

  local port="$1"

  if ss -tuln | grep -q ":$port "; then
      warn "Port $port already in use"
      return 0
  else
      ok "Port $port available"
      return 1
  fi

}

check_directory_exists() {

  local dir="$1"

  if [ -d "$dir" ]; then
      ok "Directory exists: $dir"
  else
      warn "Directory missing: $dir"
  fi

}

check_file_exists() {

  local file="$1"

  if [ -f "$file" ]; then
      ok "File exists: $file"
  else
      warn "File missing: $file"
  fi

}