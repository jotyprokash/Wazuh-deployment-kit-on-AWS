# Troubleshooting Guide

This document lists common issues encountered during deployment.

---

## Docker Permission Error

Error:

permission denied while trying to connect to docker socket

Solution:

Add your user to the docker group.

sudo usermod -aG docker $USER

Apply group change:

newgrp docker

---

## Wazuh Indexer Fails to Start

Cause:

OpenSearch requires sufficient memory.

Solution:

Adjust memory settings in:

config/wazuh_indexer.env

Example:

OPENSEARCH_JAVA_OPTS=-Xms2g -Xmx2g

---

## SSL Certificate Fails

Cause:

DNS record not propagated.

Solution:

Verify DNS resolution.

dig yourdomain.com

Wait for DNS propagation before running SSL setup.

---

## Nginx Configuration Error

Test configuration:

sudo nginx -t

Reload Nginx:

sudo systemctl reload nginx

---

## Containers Not Running

Check container status.

docker ps

Check logs.

docker logs wazuh-manager