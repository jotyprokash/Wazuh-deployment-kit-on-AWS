#!/usr/bin/env bash

#############################################
# Validation Module
# Shared environment checks for deployment
#############################################

#############################################
# Check Internet Connectivity
#############################################

check_internet() {

  info "Checking internet connectivity..."

  if ping -c 1 8.8.8.8 &>/dev/null; then
      ok "Internet connectivity available"
  else
      error "No internet connectivity detected"
      exit 1
  fi

}

#############################################
# Check Docker Installation
#############################################

check_docker() {

  info "Checking Docker installation..."

  if command -v docker &>/dev/null; then
      ok "Docker is installed"
  else
      error "Docker is not installed. Run Server Readiness first."
      exit 1
  fi

}

#############################################
# Check Docker Compose
#############################################

check_compose() {

  info "Checking Docker Compose..."

  if docker compose version &>/dev/null; then
      ok "Docker Compose available"
  else
      error "Docker Compose not installed"
      exit 1
  fi

}

#############################################
# Check Required Ports
#############################################

check_ports() {

  info "Checking required ports availability..."

  REQUIRED_PORTS=(443 1514 1515)

  for port in "${REQUIRED_PORTS[@]}"; do
      if ss -tuln | grep -q ":$port "; then
          warn "Port $port already in use"
      else
          ok "Port $port available"
      fi
  done

}

#############################################
# Check Disk Space
#############################################

check_disk_space() {

  info "Checking disk space..."

  AVAILABLE=$(df / | awk 'NR==2 {print $4}')

  if [ "$AVAILABLE" -lt 10485760 ]; then
      warn "Low disk space available"
  else
      ok "Disk space sufficient"
  fi

}

#############################################
# Check Memory Availability
#############################################

check_memory() {

  info "Checking system memory..."

  RAM=$(free -g | awk '/Mem:/ {print $2}')

  if [ "$RAM" -lt 4 ]; then
      warn "System memory less than recommended (4GB)"
  else
      ok "Memory requirement satisfied"
  fi

}

#############################################
# Validate Domain DNS
#############################################

check_dns() {

  local domain="$1"

  info "Checking DNS resolution for $domain..."

  if dig +short "$domain" | grep -q "."; then
      ok "DNS resolution successful"
  else
      warn "DNS not resolving yet"
      return 1
  fi

}

#############################################
# Validate Wazuh Containers
#############################################

check_wazuh_containers() {

  info "Checking Wazuh containers..."

  if docker ps | grep -q wazuh; then
      ok "Wazuh containers running"
  else
      error "Wazuh containers not running"
      return 1
  fi

}

#############################################
# Validate Nginx Status
#############################################

check_nginx() {

  step "Checking Nginx installation"

  if ! command -v nginx >/dev/null 2>&1; then
      warn "Nginx not found. Installing..."
      sudo apt update -y
      sudo apt install nginx -y
  fi

  ok "Nginx available"

}

#############################################
# Validate SSL Certificate
#############################################

check_ssl_certificate() {

  local domain="$1"

  info "Validating SSL certificate for $domain..."

  if echo | openssl s_client -connect "$domain:443" -servername "$domain" 2>/dev/null | grep -q "Verify return code: 0"; then
      ok "SSL certificate valid"
  else
      warn "SSL certificate validation failed"
  fi

}