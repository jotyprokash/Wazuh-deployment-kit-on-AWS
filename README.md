# Wazuh Deployment Kit (AWS)

A lightweight DevOps automation toolkit to deploy a **Dockerized Wazuh security monitoring platform** on an AWS EC2 instance.

This project provides modular scripts to prepare a server, deploy Wazuh, configure Nginx reverse proxy, enable HTTPS with Let's Encrypt, and safely remove the deployment.


## Features

* Automated server readiness setup
* Dockerized Wazuh deployment
* Nginx reverse proxy configuration
* Let's Encrypt SSL automation
* Modular script architecture
* Safe removal workflow

## Requirements

Recommended minimum resources:

* **2 vCPU**
* **4 GB RAM**
* **30 GB Storage**
* **Ubuntu 20.04 / 22.04**


## Installation

Clone the repository:

```bash
git clone https://github.com/jotyprokash/Wazuh-deployment-kit-on-AWS.git
cd Wazuh-deployment-kit-on-aws
```

Make scripts executable:

```bash
chmod +x deploy.sh
chmod +x scripts/*.sh
chmod +x lib/*.sh
```


## Usage

Run the deployment toolkit:

```bash
./deploy.sh
```

Menu options:

```
1) Validate Server Readiness
2) Deploy Wazuh XDR Platform
3) Configure Domain Reverse Proxy (Nginx)
4) Enable HTTPS (Let's Encrypt SSL)
5) Remove Wazuh Deployment
6) Exit Deployment Tool
```


## Security

* Dashboard exposed only via **HTTPS**
* Internal Wazuh dashboard port protected behind **Nginx reverse proxy**
* TLS certificates issued via **Let's Encrypt**


## Documentation

Additional documentation is available in:

```
docs/
```


## License

MIT License
