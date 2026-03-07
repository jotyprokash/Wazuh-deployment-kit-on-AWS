# Architecture Overview

This repository provides an automated deployment toolkit for running a minimal Wazuh security monitoring platform on AWS.

The deployment targets a lightweight EC2 instance while maintaining centralized log monitoring and security visibility.

## Architecture Components

EC2 Instance
- Ubuntu Server
- Docker Engine
- Docker Compose

Wazuh Stack (Docker)
- wazuh-manager
- wazuh-indexer
- wazuh-dashboard

Reverse Proxy
- Nginx

TLS Security
- Let's Encrypt SSL via Certbot

## Traffic Flow

User → HTTPS 443 → Nginx → Wazuh Dashboard Container

## Monitored Systems

AWS Dev Servers connect to the Wazuh manager using the Wazuh agent protocol.

Ports used internally:

1514 — Agent log ingestion  
1515 — Agent enrollment  
5601 — Wazuh dashboard (internal)

Externally exposed:

443 — Secure dashboard access

## Deployment Model

Single-node Wazuh deployment designed for:

- Small environments
- Development security monitoring
- Cost-optimized infrastructure

The architecture can be scaled later to a distributed cluster if required.