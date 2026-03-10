#!/usr/bin/env bash

set -u

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load libraries
source "$BASE_DIR/lib/ui.sh"
source "$BASE_DIR/lib/logger.sh"

# Load modules
source "$BASE_DIR/scripts/server_readiness.sh"
source "$BASE_DIR/scripts/deploy_wazuh.sh"
source "$BASE_DIR/scripts/nginx_setup.sh"
source "$BASE_DIR/scripts/ssl_setup.sh"
source "$BASE_DIR/scripts/remove_wazuh.sh"

init_log

while true; do
  clear

  print_line
  echo "           WAZUH DEPLOYMENT"
  echo "      Minimal • Secure • Reusable • AWS"
  print_line

  echo "1) Validate Server Readiness"
  echo "2) Deploy Wazuh XDR Platform"
  echo "3) Configure Domain Reverse Proxy (Nginx)"
  echo "4) Enable HTTPS (Let's Encrypt SSL)"
  echo "5) Remove Wazuh Deployment"
  echo "6) Exit Deployment Tool"
  echo ""

  read -r -p "Select an operation [1-6]: " choice

  case "$choice" in

    1)
      step "Running Server Readiness Validation"
      log_msg "INFO" "User selected Server Readiness Validation"
      run_server_readiness
      pause_screen
      ;;

    2)
      step "Deploying Wazuh XDR Platform"
      log_msg "INFO" "User selected Wazuh Deployment"
      run_wazuh_deployment
      pause_screen
      ;;

    3)
      step "Configuring Domain Reverse Proxy"
      log_msg "INFO" "User selected Domain Reverse Proxy Setup"
      run_nginx_setup
      pause_screen
      ;;

    4)
      step "Enabling HTTPS using Let's Encrypt"
      log_msg "INFO" "User selected SSL Setup"
      run_ssl_setup
      pause_screen
      ;;

    5)
      step "Removing Wazuh Deployment"
      log_msg "INFO" "User selected Wazuh Removal"
      run_wazuh_removal
      pause_screen
      ;;

    6)
      info "Exiting deployment tool."
      log_msg "INFO" "User exited the script"
      exit 0
      ;;

    *)
      warn "Invalid selection. Please choose a valid option between 1 and 6."
      pause_screen
      ;;

  esac

done