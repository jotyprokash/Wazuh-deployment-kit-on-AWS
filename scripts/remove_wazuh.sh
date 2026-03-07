#!/usr/bin/env bash

#############################################
# Remove Wazuh Module (Soft Remove)
# Cleans Wazuh deployment from the server
#############################################

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$BASE_DIR/lib/ui.sh"
source "$BASE_DIR/scripts/validations.sh"

WAZUH_DIR="$HOME/wazuh-docker"

#############################################
# Main Removal Function
#############################################

run_wazuh_removal() {

  print_line
  step "Starting Wazuh removal process"
  print_line

  confirm_removal
  stop_containers
  remove_wazuh_repo
  remove_nginx_config
  remove_ssl_certificate
  reload_nginx

  print_line
  ok "Wazuh removal completed successfully"
  print_line

}

#############################################
# Confirm Removal
#############################################

confirm_removal() {

  warn "This will remove the Wazuh deployment from this server."

  if ask_yes_no "Do you want to continue?"; then
      ok "Proceeding with removal"
  else
      info "Removal cancelled"
      exit 0
  fi

}

#############################################
# Stop Wazuh Containers
#############################################

stop_containers() {

  step "Stopping Wazuh containers"

  if [ -d "$WAZUH_DIR/single-node" ]; then

      cd "$WAZUH_DIR/single-node" || exit

      docker compose down

      ok "Wazuh containers stopped"

  else

      warn "Wazuh repository not found — skipping container shutdown"

  fi

}

#############################################
# Remove Wazuh Repository
#############################################

remove_wazuh_repo() {

  step "Removing Wazuh Docker repository"

  if [ -d "$WAZUH_DIR" ]; then

      rm -rf "$WAZUH_DIR"

      ok "Wazuh repository removed"

  else

      warn "Repository not found"

  fi

}

#############################################
# Remove Nginx Configuration
#############################################

remove_nginx_config() {

  step "Removing Nginx configuration"

  NGINX_SITE="/etc/nginx/sites-available/wazuh"
  NGINX_ENABLED="/etc/nginx/sites-enabled/wazuh"

  if [ -f "$NGINX_SITE" ]; then

      sudo rm -f "$NGINX_SITE"

      ok "Nginx site config removed"

  else

      warn "Nginx site config not found"

  fi

  if [ -L "$NGINX_ENABLED" ]; then

      sudo rm -f "$NGINX_ENABLED"

      ok "Nginx site symlink removed"

  else

      warn "Nginx enabled site not found"

  fi

}

#############################################
# Remove SSL Certificate
#############################################

remove_ssl_certificate() {

  step "Removing SSL certificate"

  read -rp "Enter the domain used for Wazuh (example: wazuh.example.com): " DOMAIN

  if [ -z "$DOMAIN" ]; then
      warn "Domain not provided — skipping SSL removal"
      return
  fi

  if sudo certbot certificates | grep -q "$DOMAIN"; then

      sudo certbot delete --cert-name "$DOMAIN"

      ok "SSL certificate removed"

  else

      warn "No SSL certificate found for $DOMAIN"

  fi

}

#############################################
# Reload Nginx
#############################################

reload_nginx() {

  step "Reloading Nginx"

  sudo nginx -t
  sudo systemctl reload nginx

  ok "Nginx reloaded"

}