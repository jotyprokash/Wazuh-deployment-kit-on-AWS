#!/usr/bin/env bash

set -u

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=lib/ui.sh
source "$BASE_DIR/lib/ui.sh"
# shellcheck source=lib/logger.sh
source "$BASE_DIR/lib/logger.sh"

# shellcheck source=scripts/server_readiness.sh
source "$BASE_DIR/scripts/server_readiness.sh"
# shellcheck source=scripts/deploy_wazuh.sh
source "$BASE_DIR/scripts/deploy_wazuh.sh"
# shellcheck source=scripts/remove_wazuh.sh
source "$BASE_DIR/scripts/remove_wazuh.sh"

init_log

while true; do
  clear
  show_menu
  read -r -p "Enter your choice [1-4]: " choice

  case "$choice" in
    1)
      step "Launching Server Readiness..."
      log_msg "INFO" "User selected Server Readiness"
      run_server_readiness
      pause_screen
      ;;
    2)
      step "Launching Wazuh Deployment..."
      log_msg "INFO" "User selected Deploy Wazuh"
      run_wazuh_deployment
      pause_screen
      ;;
    3)
      step "Launching Wazuh Removal..."
      log_msg "INFO" "User selected Remove Wazuh"
      run_wazuh_removal
      pause_screen
      ;;
    4)
      info "Exiting."
      log_msg "INFO" "User exited the script"
      exit 0
      ;;
    *)
      warn "Invalid choice. Please select between 1 and 4."
      pause_screen
      ;;
  esac
done