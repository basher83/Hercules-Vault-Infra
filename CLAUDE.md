# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Terraform-based Infrastructure-as-Code repository for deploying a highly available HashiCorp Vault cluster to Proxmox production infrastructure using Scalr for workflow automation.

**Architecture**: Production-ready Vault cluster consisting of 1x Master Vault (auto-unseal provider) and 3x Production Vault Nodes (Raft cluster)

## Common Commands

### Terraform Operations

```bash
# Change to environment directory
cd infrastructure/environments/production

# Initialize Terraform
terraform init

# Format Terraform files
terraform fmt -recursive

# Validate configuration
terraform validate

# Plan infrastructure changes
terraform plan

# Apply changes (typically done through Scalr)
terraform apply
```

### Documentation Generation

```bash
# Generate terraform-docs for all modules and environments
./scripts/generate-docs.sh

# Requires terraform-docs to be installed
mise install terraform-docs
```

### Mise Task Management

```bash
# Format, lint, and validate production environment
mise run check

# Individual tasks
mise run fmt           # Format Terraform files
mise run lint-prod     # Lint production environment
mise run prod-validate # Validate production configuration
```

### Development Scripts

```bash
# Find all tags used across Terraform files
./scripts/find-tags.sh

# Setup SSH access to Proxmox for file uploads
./scripts/setup-proxmox-ssh.sh
```

## Architecture and Structure

### Project Layout

- **infrastructure/environments/production/** - Production Vault cluster deployment
- **infrastructure/modules/vm/** - Reusable Proxmox VM provisioning module
- **infrastructure/scalr-management/** - Scalr workspace and provider configuration management
- **scripts/** - Essential utilities (tag discovery, docs generation, SSH setup)
- **docs/** - Infrastructure requirements documentation

### Key Architectural Patterns

1. **Production-Focused**: Single production environment for focused Vault cluster deployment
2. **Modular Design**: VM provisioning abstracted into reusable module (`modules/vm/`)
3. **Scalr Integration**: Remote state management and CI/CD through Scalr workspaces
4. **High Availability**: VMs distributed across multiple Proxmox nodes (lloyd, holly, mable)
5. **Cloud-init Automation**: Automated Vault installation and QEMU agent setup via cloud-init snippets

### VM Module Structure

The VM module (`infrastructure/modules/vm/`) provides:
- Proxmox VM provisioning using `bpg/proxmox` provider
- Cloud-init snippet integration for automated Vault + QEMU agent installation
- Single NIC network configuration optimized for Vault cluster
- EFI boot support with Secure Boot
- Configurable CPU, memory, and disk specifications
- Tag-based resource organization

### Production Environment Layout

The production environment creates 4 VMs with specific roles:
- `vault-master` (192.168.10.30) - Auto-unseal provider, 2 vCPU, 4GB RAM
- `vault-prod-1` (192.168.10.31) - Production node 1, 4 vCPU, 8GB RAM
- `vault-prod-2` (192.168.10.32) - Production node 2, 4 vCPU, 8GB RAM  
- `vault-prod-3` (192.168.10.33) - Production node 3, 4 vCPU, 8GB RAM

### Scalr Configuration

- **Workspace Management**: `infrastructure/scalr-management/` contains Terraform code to create and configure Scalr workspaces
- **VCS Integration**: `scalr.yaml` defines workspace triggers and hooks
- **Remote State**: All environments use Scalr backend for state management
- **Variable Management**: Sensitive values (API tokens, SSH keys) stored in Scalr workspace variables

## Provider and Version Requirements

- **Terraform**: >= 1.3.0
- **Proxmox Provider**: bpg/proxmox >= 0.73.2
- **Template Requirements**: Ubuntu 22.04 template (ID: 8000) in Proxmox

## Required Scalr Variables

Configure these variables in the Scalr workspace:

| Variable | Type | Sensitive | Description |
|----------|------|-----------|-------------|
| `pve_api_url` | string | No | Proxmox API endpoint |
| `pve_api_token` | string | Yes | Proxmox API token |
| `ci_ssh_key` | string | No | SSH public key for VM access |
| `vm_datastore` | string | No | Proxmox storage datastore |
| `vm_bridge_1` | string | No | Primary network bridge |

## Development Workflow

1. Make changes in feature branch
2. Run `mise run check` to validate locally
3. Scalr automatically triggers plan on push
4. Review plan output in Scalr UI
5. Apply through Scalr for production deployment
6. VMs automatically configured via cloud-init (no manual post-deployment needed)

## Important Notes

- **Cloud-init handles all VM provisioning** - Vault and QEMU agent installed automatically
- **Production-only focus** - Non-production environments removed for simplicity
- **nftables firewall management** - No UFW or other conflicting firewall services
- Never commit `terraform.tfvars` files with actual values
- Use `terraform.tfvars.example` as template
- All sensitive variables must be configured in Scalr
- State is managed remotely - never commit `.tfstate` files
- VM IDs use offset system (production: 3000+) to avoid conflicts
- All resources are tagged for identification and management