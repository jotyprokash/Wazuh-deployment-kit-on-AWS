#!/usr/bin/env bash

#############################################
# Nginx Reverse Proxy Setup
# Configures domain reverse proxy for Wazuh
#############################################

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$BASE_DIR/lib/ui.sh"
source "$BASE_DIR/scripts/validations.sh"

#############################################
# Main Function
#############################################

run_nginx_setup() {

  print_line
  step "Configuring Nginx reverse proxy"
  print_line

  check_nginx

  ask_domain
  create_nginx_config
  enable_nginx_site
  reload_nginx
  verify_nginx

  print_line
  ok "Nginx reverse proxy configured successfully"
  print_line

}

#############################################
# Ask Domain Name
#############################################

ask_domain() {

  read -rp "Enter domain for Wazuh dashboard (example: wazuh.example.com): " DOMAIN

  if [ -z "$DOMAIN" ]; then
      error "Domain cannot be empty"
      exit 1
  fi

  ok "Domain set to $DOMAIN"

}

#############################################
# Create Nginx Configuration
#############################################

create_nginx_config() {

  step "Creating Nginx configuration"

  NGINX_CONF="/etc/nginx/sites-available/wazuh"

  sudo tee "$NGINX_CONF" > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass https://127.0.0.1:5601;
        proxy_ssl_verify off;

        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

  ok "Nginx configuration created"

}

#############################################
# Enable Nginx Site
#############################################

enable_nginx_site() {

  step "Enabling Nginx site"

  sudo ln -sf /etc/nginx/sites-available/wazuh /etc/nginx/sites-enabled/wazuh

  ok "Site enabled"

}

#############################################
# Reload Nginx
#############################################

reload_nginx() {

  step "Testing Nginx configuration"

  sudo nginx -t

  step "Reloading Nginx service"

  sudo systemctl reload nginx

  ok "Nginx reloaded"

}

#############################################
# Verify Nginx Setup
#############################################

verify_nginx() {

  step "Verifying Nginx status"

  if systemctl is-active --quiet nginx; then
      ok "Nginx is running"
  else
      error "Nginx service is not running"
      exit 1
  fi

}