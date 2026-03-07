#!/usr/bin/env bash

#############################################
# SSL Setup Module
# Configures Let's Encrypt SSL for Wazuh
#############################################

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$BASE_DIR/lib/ui.sh"
source "$BASE_DIR/scripts/validations.sh"

#############################################
# Main SSL Setup Function
#############################################

run_ssl_setup() {

  print_line
  step "Starting SSL configuration"
  print_line

  check_nginx

  ask_domain
  confirm_dns
  install_certificate
  verify_ssl

  print_line
  ok "SSL configuration completed successfully"
  print_line

}

#############################################
# Ask Domain
#############################################

ask_domain() {

  read -rp "Enter domain configured for Wazuh (example: wazuh.example.com): " DOMAIN

  if [ -z "$DOMAIN" ]; then
      error "Domain cannot be empty"
      exit 1
  fi

  ok "Domain set to $DOMAIN"

}

#############################################
# Confirm DNS Setup
#############################################

confirm_dns() {

  step "Checking DNS configuration"

  if check_dns "$DOMAIN"; then
      ok "DNS appears to be configured"
  else
      warn "DNS may not be fully propagated yet"
  fi

  if ask_yes_no "Has the domain DNS already been pointed to this server?"; then
      ok "Continuing with SSL setup"
  else
      warn "Please configure DNS A record first"
      echo
      echo "Example DNS record:"
      echo "$DOMAIN -> <EC2_PUBLIC_IP>"
      echo
      read -rp "Press ENTER once DNS is configured..."
  fi

}

#############################################
# Install SSL Certificate
#############################################

install_certificate() {

  step "Requesting SSL certificate from Let's Encrypt"

  sudo certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos --redirect -m admin@"$DOMAIN" || {

      error "Certbot failed to obtain certificate"
      exit 1

  }

  ok "SSL certificate installed"

}

#############################################
# Verify SSL
#############################################

verify_ssl() {

  step "Validating SSL certificate"

  if check_ssl_certificate "$DOMAIN"; then
      ok "SSL certificate verified"
  else
      warn "SSL validation returned warnings"
  fi

  print_line
  info "Wazuh Dashboard is now available at:"
  echo
  echo "https://$DOMAIN"
  echo

}