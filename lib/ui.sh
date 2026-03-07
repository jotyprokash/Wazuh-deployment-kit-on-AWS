#!/usr/bin/env bash

print_line() {
  printf '%s\n' "-----------------------------------------------------"
}

print_banner() {
  if [[ -f "$(dirname "${BASH_SOURCE[0]}")/../assets/banner.txt" ]]; then
    cat "$(dirname "${BASH_SOURCE[0]}")/../assets/banner.txt"
  else
    echo "WAZUH DEPLOYMENT"
  fi
}

info() {
  printf '[INFO] %s\n' "$1"
}

step() {
  printf '[STEP] %s\n' "$1"
}

ok() {
  printf '[OK] %s\n' "$1"
}

warn() {
  printf '[WARN] %s\n' "$1"
}

error() {
  printf '[ERROR] %s\n' "$1"
}

ask_yes_no() {
  local prompt="$1"
  local reply
  read -r -p "$prompt [y/N]: " reply
  [[ "$reply" =~ ^[Yy]$ ]]
}

pause_screen() {
  read -r -p "Press Enter to continue..."
}

show_menu() {
  print_banner
  echo
  echo "Select an action:"
  echo "1) Server Readiness"
  echo "2) Deploy Wazuh"
  echo "3) Remove Wazuh"
  echo "4) Exit"
  echo
}