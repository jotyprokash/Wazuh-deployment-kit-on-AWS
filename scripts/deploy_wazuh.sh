#!/usr/bin/env bash

#############################################
# Wazuh Deployment Module
# Deploys Dockerized Wazuh Single Node
# Optimized for AWS t4g.medium
#############################################

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$BASE_DIR/lib/ui.sh"
source "$BASE_DIR/scripts/validations.sh"

WAZUH_DIR="$HOME/wazuh-docker"
WAZUH_SINGLE_NODE="$WAZUH_DIR/single-node"

#############################################
# Detect Docker Compose command
#############################################

detect_compose_command() {
  if command -v docker-compose >/dev/null 2>&1; then
    COMPOSE_CMD="docker-compose"
  elif docker compose version >/dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
  else
    error "Docker Compose not found"
    exit 1
  fi
}

#############################################
# Ensure Docker permissions
#############################################

ensure_docker_permissions() {

  step "Ensuring Docker permissions"

  if ! groups | grep -q docker; then
      sudo usermod -aG docker "$USER"
      warn "User added to docker group"

      info "Restarting script with docker group permissions..."
      exec sg docker "$0"
  fi

  ok "Docker permissions OK"

}

#############################################
# Main Deployment Function
#############################################

run_wazuh_deployment() {

  print_line
  step "Starting Wazuh deployment"
  print_line

  detect_compose_command
  ensure_docker_permissions
  validate_environment
  configure_kernel
  clone_wazuh_repo
  patch_dashboard_port
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
  check_disk_space

  ok "Environment validation completed"
}

#############################################
# Configure Kernel Requirement
#############################################

configure_kernel() {

  step "Configuring kernel parameter vm.max_map_count"

  sudo sysctl -w vm.max_map_count=262144 >/dev/null

  if grep -q '^vm.max_map_count=' /etc/sysctl.conf; then
    sudo sed -i 's/^vm.max_map_count=.*/vm.max_map_count=262144/' /etc/sysctl.conf
  else
    echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf >/dev/null
  fi

  if sysctl vm.max_map_count 2>/dev/null | grep -q "262144"; then
    ok "Kernel parameter configured"
  else
    error "Failed to configure vm.max_map_count"
    exit 1
  fi
}

#############################################
# Clone Wazuh Docker Repository
#############################################

clone_wazuh_repo() {

  step "Preparing Wazuh Docker repository"

  if [ -d "$WAZUH_DIR/.git" ]; then
    warn "Wazuh repository already exists, updating to v4.14.3"
    git -C "$WAZUH_DIR" fetch --tags origin || {
      error "Failed to fetch Wazuh repository"
      exit 1
    }
    git -C "$WAZUH_DIR" checkout v4.14.3 || {
      error "Failed to checkout Wazuh v4.14.3"
      exit 1
    }
  else
    git clone https://github.com/wazuh/wazuh-docker.git -b v4.14.3 "$WAZUH_DIR" || {
      error "Failed to clone Wazuh repository"
      exit 1
    }
  fi

  if [ ! -d "$WAZUH_SINGLE_NODE" ]; then
    error "Single-node directory not found: $WAZUH_SINGLE_NODE"
    exit 1
  fi

  ok "Wazuh repository ready"
}

#############################################
# Patch Dashboard Port (prepare for Nginx)
#############################################

patch_dashboard_port() {

  step "Patching dashboard port for reverse proxy setup"

  COMPOSE_FILE="$WAZUH_SINGLE_NODE/docker-compose.yml"

  if [ ! -f "$COMPOSE_FILE" ]; then
      error "docker-compose.yml not found"
      exit 1
  fi

  # Replace any 443:5601 exposure with localhost binding
  sed -i 's/443:5601/127.0.0.1:5601:5601/g' "$COMPOSE_FILE"
  sed -i 's/"443:5601"/"127.0.0.1:5601:5601"/g' "$COMPOSE_FILE"

  ok "Dashboard port patched to localhost:5601"

}


#############################################
# Generate TLS Certificates
#############################################

generate_wazuh_certs() {

  step "Generating Wazuh TLS certificates"

  cd "$WAZUH_SINGLE_NODE" || exit 1

  $COMPOSE_CMD -f generate-indexer-certs.yml run --rm generator

  CERT_DIR="$WAZUH_SINGLE_NODE/config/wazuh_indexer_ssl_certs"

  # Fix permissions because generator runs as root
  sudo chown -R $USER:$USER "$CERT_DIR" 2>/dev/null

  if [ ! -d "$CERT_DIR" ]; then
      error "Certificate directory not found: $CERT_DIR"
      exit 1
  fi

  for cert in admin.pem root-ca.pem wazuh.dashboard.pem wazuh.indexer.pem wazuh.manager.pem
  do
      if [ ! -f "$CERT_DIR/$cert" ]; then
          error "Missing certificate file: $cert"
          exit 1
      fi
  done

  ok "Certificates generated successfully"

}

#############################################
# Configure OpenSearch Memory
#############################################

configure_memory() {

  step "Configuring OpenSearch memory"

  COMPOSE_FILE="$WAZUH_SINGLE_NODE/docker-compose.yml"

  if [ ! -f "$COMPOSE_FILE" ]; then
      error "docker-compose.yml not found"
      exit 1
  fi

  sed -i 's/-Xms2g -Xmx2g/-Xms1g -Xmx1g/g' "$COMPOSE_FILE" 2>/dev/null

  ok "OpenSearch heap adjusted for t4g.medium (1GB)"

}

#############################################
# Start Wazuh Containers
#############################################

start_wazuh_containers() {

  step "Starting Wazuh containers"

  cd "$WAZUH_SINGLE_NODE" || exit 1

  eval "$COMPOSE_CMD up -d" || {
    error "Failed to start Wazuh containers"
    exit 1
  }

  ok "Docker containers started"
}

#############################################
# Wait for Containers
#############################################

wait_for_containers() {

  step "Waiting for Wazuh services to initialize"

  sleep 30

  RUNNING=$(docker ps --format "{{.Names}}" | grep -c "wazuh")

  if [ "$RUNNING" -ge 3 ]; then
      ok "Wazuh containers are running"
  else
      error "Wazuh containers failed to start"
      docker ps
      exit 1
  fi

}

#############################################
# Verify Indexer Health
#############################################

verify_indexer() {

  step "Checking Wazuh indexer logs"

  if docker logs single-node_wazuh.indexer_1 2>&1 | grep -qi "OutOfMemory"; then
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