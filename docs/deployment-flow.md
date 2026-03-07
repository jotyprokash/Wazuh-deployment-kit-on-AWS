# Deployment Flow

The toolkit uses a modular deployment workflow.

Each module is responsible for a specific task.

## Step 1 — Server Readiness

Prepares the system for deployment.

Tasks performed:

- Verify Ubuntu environment
- Install Docker
- Install Docker Compose
- Install Nginx
- Install Certbot
- Validate memory and disk

Script used:

scripts/server_readiness.sh

---

## Step 2 — Wazuh Deployment

Deploys the Wazuh stack using Docker.

Tasks performed:

- Clone official Wazuh Docker repository
- Configure memory for OpenSearch
- Launch containers using Docker Compose
- Verify container health

Script used:

scripts/deploy_wazuh.sh

---

## Step 3 — Nginx Configuration

Configures reverse proxy access.

Tasks performed:

- Create Nginx configuration
- Enable site
- Reload Nginx

Script used:

scripts/nginx_setup.sh

---

## Step 4 — SSL Setup

Enables secure HTTPS access.

Tasks performed:

- Verify DNS resolution
- Request certificate using Certbot
- Enable HTTPS redirection

Script used:

scripts/ssl_setup.sh

---

## Step 5 — Removal

Allows safe cleanup of the deployment.

Tasks performed:

- Stop Wazuh containers
- Remove repository
- Remove Nginx configuration
- Remove SSL certificate

Script used:

scripts/remove_wazuh.sh