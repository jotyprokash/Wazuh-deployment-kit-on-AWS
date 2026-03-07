#!/usr/bin/env bash

#############################################
# Server Readiness Module
# Prepares EC2 instance for Wazuh deployment
#############################################

run_server_readiness() {

  print_line
  step "Starting server readiness checks"
  print_line

  check_os
  check_sudo
  check_memory
  check_disk
  update_system
  install_basic_tools
  install_docker
  install_compose
  install_nginx
  install_certbot

  print_line
  ok "Server readiness completed successfully"
  print_line
}

#############################################
# Check Operating System
#############################################

check_os() {

  info "Checking operating system..."

  if grep -qi ubuntu /etc/os-release; then
      ok "Ubuntu detected"
  else
      error "This script supports Ubuntu only"
      exit 1
  fi

}

#############################################
# Check sudo privileges
#############################################

check_sudo() {

  info "Checking sudo privileges..."

  if sudo -n true 2>/dev/null; then
      ok "Sudo access verified"
  else
      warn "You may be prompted for sudo password"
  fi

}

#############################################
# Check Memory
#############################################

check_memory() {

  info "Checking system memory..."

  RAM=$(free -g | awk '/Mem:/ {print $2}')

  if [ "$RAM" -lt 4 ]; then
      warn "System memory is less than recommended (4GB)"
  else
      ok "Memory check passed (${RAM}GB)"
  fi

}

#############################################
# Check Disk Space
#############################################

check_disk() {

  info "Checking disk space..."

  DISK=$(df -h / | awk 'NR==2 {print $4}')

  ok "Available disk space: $DISK"

}

#############################################
# Update System
#############################################

update_system() {

  step "Updating system packages"

  sudo apt update -y
  sudo apt upgrade -y

  ok "System updated"

}

#############################################
# Install Basic Tools
#############################################

install_basic_tools() {

  step "Installing basic utilities"

  sudo apt install -y \
  curl \
  git \
  apt-transport-https \
  ca-certificates \
  software-properties-common

  ok "Basic tools installed"

}

#############################################
# Install Docker
#############################################

install_docker() {

  step "Installing Docker"

  if command -v docker &> /dev/null; then
      ok "Docker already installed"
      return
  fi

  curl -fsSL https://get.docker.com | sudo bash

  sudo usermod -aG docker "$USER"

  ok "Docker installed"

  warn "Docker group added. If docker command fails run: newgrp docker"

}

#############################################
# Install Docker Compose Plugin
#############################################

install_compose() {

  step "Installing Docker Compose plugin"

  if docker compose version &> /dev/null; then
      ok "Docker Compose already installed"
      return
  fi

  sudo apt install -y docker-compose-plugin

  ok "Docker Compose installed"

}

#############################################
# Install Nginx
#############################################

install_nginx() {

  step "Installing Nginx"

  if systemctl is-active --quiet nginx; then
      ok "Nginx already installed"
      return
  fi

  sudo apt install -y nginx

  sudo systemctl enable nginx
  sudo systemctl start nginx

  ok "Nginx installed and running"

}

#############################################
# Install Certbot
#############################################

install_certbot() {

  step "Installing Certbot for SSL"

  if command -v certbot &> /dev/null; then
      ok "Certbot already installed"
      return
  fi

  sudo apt install -y certbot python3-certbot-nginx

  ok "Certbot installed"

}