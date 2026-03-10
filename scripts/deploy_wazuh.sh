#!/usr/bin/env bash

#############################################
# Wazuh Deployment Module
# Dockerized Wazuh Single Node
# Optimized for AWS t4g.medium
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
  configure_kernel
  clone_wazuh_repo
  generate_wazuh_certs
  configure_memory
  start_wazuh_containers
  wait_for_containers
  verify_indexer
  show_access_info

  print_line
  ok "Wazuh deployment completed successfully"
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
  check_disk_space

  ok "Environment validation completed"
}

#############################################
# Configure Kernel Requirement
#############################################

configure_kernel() {

  step "Configuring kernel parameter vm.max_map_count"

  sudo sysctl -w vm.max_map_count=262144 >/dev/null

  if ! grep -q vm.max_map_count /etc/sysctl.conf; then
      echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf >/dev/null
  fi

  ok "Kernel parameter configured"

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

  git clone https://github.com/wazuh/wazuh-docker.git -b v4.14.3 "$WAZUH_DIR"

  ok "Wazuh repository cloned"

}

#############################################
# Generate TLS Certificates
#############################################

generate_wazuh_certs() {

  step "Generating Wazuh TLS certificates"

  cd "$WAZUH_SINGLE_NODE" || exit 1

  docker-compose -f generate-indexer-certs.yml run --rm generator

  ok "Certificates generated"

}

#############################################
# Configure OpenSearch Memory
#############################################

configure_memory() {

  step "Configuring OpenSearch memory"

  ENV_FILE="$WAZUH_SINGLE_NODE/config/wazuh_indexer.env"

  if [ ! -f "$ENV_FILE" ]; then
      error "Indexer configuration file not found"
      exit 1
  fi

  sed -i 's/OPENSEARCH_JAVA_OPTS=.*/OPENSEARCH_JAVA_OPTS=-Xms1g -Xmx1g/' "$ENV_FILE"

  ok "Memory tuned for t4g.medium (4GB RAM)"

}

#############################################
# Start Wazuh Containers
#############################################

start_wazuh_containers() {

  step "Starting Wazuh containers"

  cd "$WAZUH_SINGLE_NODE" || exit 1

  docker-compose up -d

  ok "Docker containers started"

}

#############################################
# Wait for Containers
#############################################

wait_for_containers() {

  step "Waiting for Wazuh services to initialize"

  sleep 20

  if docker ps | grep -q wazuh; then
      ok "Wazuh containers are running"
  else
      error "Wazuh containers failed to start"
      exit 1
  fi

}

#############################################
# Verify Indexer Health
#############################################

verify_indexer() {

  step "Checking Wazuh indexer logs"

  if docker logs single-node_wazuh.indexer_1 | grep -i "OutOfMemory" >/dev/null; then
      error "Indexer memory issue detected"
      exit 1
  fi

  ok "Indexer running without memory errors"

}

#############################################
# Show Access Information
#############################################

show_access_info() {

  print_line

  info "Wazuh dashboard is available"

  echo
  echo "Access URL:"
  echo "https://<EC2_PUBLIC_IP>"
  echo
  echo "Default credentials:"
  echo "Username: admin"
  echo "Password: SecretPassword"
  echo

}