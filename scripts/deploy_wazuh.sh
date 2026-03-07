#!/usr/bin/env bash

#############################################
# Wazuh Deployment Module
# Deploys Dockerized Wazuh Single Node
#############################################

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$BASE_DIR/lib/ui.sh"
source "$BASE_DIR/scripts/validations.sh"

WAZUH_DIR="$HOME/wazuh-docker"
WAZUH_SINGLE_NODE="$WAZUH_DIR/single-node"

#############################################
# Main Deployment Function
#############################################

run_wazuh_deployment() {

  print_line
  step "Starting Wazuh deployment"
  print_line

  validate_environment
  clone_wazuh_repo
  configure_memory
  start_wazuh_containers
  wait_for_containers
  show_access_info

  print_line
  ok "Wazuh deployment completed"
  print_line
}

#############################################
# Environment Validation
#############################################

validate_environment() {

  step "Validating deployment prerequisites"

  check_internet
  check_docker
  check_compose
  check_ports
  check_memory
  check_disk_space

  ok "Environment validation completed"

}

#############################################
# Clone Wazuh Docker Repository
#############################################

clone_wazuh_repo() {

  step "Preparing Wazuh Docker repository"

  if [ -d "$WAZUH_DIR" ]; then
      warn "Wazuh repository already exists"
      return
  fi

  git clone https://github.com/wazuh/wazuh-docker.git "$WAZUH_DIR"

  ok "Wazuh repository cloned"

}

#############################################
# Configure Memory for 4GB Server
#############################################

configure_memory() {

  step "Configuring OpenSearch memory settings"

  ENV_FILE="$WAZUH_SINGLE_NODE/config/wazuh_indexer.env"

  if [ ! -f "$ENV_FILE" ]; then
      error "Indexer configuration file not found"
      exit 1
  fi

  sed -i 's/OPENSEARCH_JAVA_OPTS=.*/OPENSEARCH_JAVA_OPTS=-Xms2g -Xmx2g/' "$ENV_FILE"

  ok "Memory tuned for 4GB instance"

}

#############################################
# Start Wazuh Containers
#############################################

start_wazuh_containers() {

  step "Starting Wazuh containers"

  cd "$WAZUH_SINGLE_NODE" || exit 1

  docker compose up -d

  ok "Docker containers started"

}

#############################################
# Wait for Containers to Initialize
#############################################

wait_for_containers() {

  step "Waiting for Wazuh services to initialize"

  sleep 15

  if docker ps | grep -q wazuh; then
      ok "Wazuh containers are running"
  else
      error "Wazuh containers failed to start"
      exit 1
  fi

}

#############################################
# Show Access Information
#############################################

show_access_info() {

  print_line
  info "Wazuh dashboard is starting"
  echo
  echo "Access URL:"
  echo "https://<server-ip>"
  echo
  echo "Default credentials will be displayed in the container logs."
  echo

}