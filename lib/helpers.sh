#!/usr/bin/env bash

#############################################
# Helper Utilities Library
# Generic reusable utilities
#############################################

random_string() {

  length=${1:-16}

  tr -dc A-Za-z0-9 </dev/urandom | head -c "$length"

}

timestamp() {

  date +"%Y-%m-%d %H:%M:%S"

}

pause() {

  read -rp "Press ENTER to continue..."

}

confirm() {

  local prompt="$1"

  read -rp "$prompt [y/N]: " response

  case "$response" in
      y|Y ) return 0 ;;
      * ) return 1 ;;
  esac

}

get_public_ip() {

  curl -s https://api.ipify.org

}

wait_for_port() {

  local host="$1"
  local port="$2"

  for i in {1..30}; do
      if nc -z "$host" "$port"; then
          return 0
      fi
      sleep 2
  done

  return 1

}

spinner() {

  local pid=$!
  local delay=0.1
  local spinstr='|/-\'

  while ps -p $pid &>/dev/null; do
      local temp=${spinstr#?}
      printf " [%c]  " "$spinstr"
      local spinstr=$temp${spinstr%"$temp"}
      sleep $delay
      printf "\b\b\b\b\b\b"
  done

  printf "    \b\b\b\b"

}