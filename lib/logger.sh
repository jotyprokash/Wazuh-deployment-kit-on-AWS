#!/usr/bin/env bash

LOG_FILE="/var/log/wazuh-deployment.log"

init_log() {
  if [[ ! -f "$LOG_FILE" ]]; then
    sudo touch "$LOG_FILE" 2>/dev/null || true
    sudo chmod 666 "$LOG_FILE" 2>/dev/null || true
  fi
}

log_msg() {
  local level="$1"
  local message="$2"
  printf '%s [%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$level" "$message" >> "$LOG_FILE" 2>/dev/null || true
}