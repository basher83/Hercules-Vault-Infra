![Terraform](https://img.shields.io/badge/terraform-000000?style=for-the-badge&logo=terraform&logoColor=)
![Vault](https://img.shields.io/badge/Vault-000000?style=for-the-badge&logo=vault&logoColor=)
![Ansible](https://img.shields.io/badge/Ansible-000000?style=for-the-badge&logo=ansible&logoColor=white)
![Proxmox](https://img.shields.io/badge/Proxmox-000000?style=for-the-badge&logo=proxmox&logoColor=)

# Hercules-Vault-Infra

Infrastructure as Code for deploying a highly available HashiCorp Vault cluster to Proxmox production infrastructure using Terraform and Scalr.

<img src="https://raw.githubusercontent.com/basher83/assets/main/space-gifs/undraw_taken_mshk.svg" width="200" alt="basher83 Aliens taken">

</div>

## 🏗️ Architecture

This repository deploys a production-ready Vault cluster consisting of:

- **1x Master Vault** - Auto-unseal provider with Transit engine (2 vCPU, 4GB RAM, 40GB SSD)
- **3x Production Vault Nodes** - High-availability Raft cluster (4 vCPU, 8GB RAM, 100GB SSD each)

Total Resources: 14 vCPUs, 28GB RAM, 340GB Storage

## 📁 Project Structure

```
infrastructure/
├── environments/
│   └── production/      # Production Vault cluster configuration
├── modules/
│   └── vm/             # Reusable Proxmox VM module
└── scalr-management/   # Scalr workspace management
scripts/                # Essential utilities
docs/                   # Infrastructure requirements
```

## 🚀 Quick Start

### Prerequisites

- Proxmox VE cluster (tested with 8.x)
- Ubuntu 22.04 template in Proxmox (ID: 8000)
- Scalr account with workspace configured
- Terraform >= 1.3.0
- mise tool manager (for task automation)

### Deployment Steps

1. **Configure Scalr Workspace Variables**
   ```hcl
   pve_api_url   = "https://your-proxmox:8006/api2/json"
   pve_api_token = "user@pam!token-id=token-secret"
   ci_ssh_key    = "ssh-ed25519 AAAA..."
   ```

2. **Validate Configuration Locally**
   ```bash
   # Format, lint, and validate all configurations
   mise run check
   ```

3. **Deploy via Scalr VCS**
   - Push changes to your linked repository
   - Scalr automatically triggers a plan
   - Review and apply through Scalr UI

4. **Automatic VM Configuration**
   - VMs are automatically configured via cloud-init
   - Vault and QEMU guest agent installed during provisioning
   - No manual post-deployment steps required

5. **Manual Deployment (Development Only)**
   ```bash
   cd infrastructure/environments/production
   terraform init
   terraform plan
   terraform apply
   ```

## 🌐 Network Configuration

| VM | IP Address | Purpose | Ports |
|---|---|---|---|
| vault-master | 192.168.10.30 | Auto-unseal Provider | 8200 |
| vault-prod-1 | 192.168.10.31 | Production Node 1 | 8200, 8201 |
| vault-prod-2 | 192.168.10.32 | Production Node 2 | 8200, 8201 |
| vault-prod-3 | 192.168.10.33 | Production Node 3 | 8200, 8201 |

## 🔧 Configuration

### Environment Variables

Required variables are configured in Scalr workspace:
- `pve_api_url` - Proxmox API endpoint
- `pve_api_token` - API authentication token
- `ci_ssh_key` - SSH key for VM access

Optional variables with defaults:
- `vault_network_subnet` - Network subnet (default: 192.168.10)
- `template_id` - Ubuntu template ID (default: 8000)
- `vm_datastore` - Storage location (default: local-lvm)

### High Availability

VMs are distributed across Proxmox nodes for fault tolerance:
- vault-master → lloyd
- vault-prod-1 → holly
- vault-prod-2 → mable
- vault-prod-3 → lloyd

## 🔐 Security Features

- **Auto-unseal**: Master Vault provides Transit engine for automatic unsealing
- **Raft Storage**: Built-in replication and consensus
- **Single NIC**: Simplified network attack surface
- **Cloud-init Automation**: Secure automated VM provisioning
- **SSH Key Auth**: No password authentication
- **nftables Firewall**: External firewall management (no conflicting services)

## 📊 Outputs

After deployment, Terraform provides:

- Vault API endpoints for all nodes
- Ansible inventory for configuration management
- Network configuration details
- Cluster resource summary

## 🛠️ Maintenance

### Backup Strategy
- Raft snapshots for data backup
- Configuration stored in Git
- State managed by Scalr

### Monitoring
- Netdata for system metrics (as per requirements doc)
- Vault telemetry endpoints
- Proxmox built-in monitoring

### Scaling
- CPU: Scale when consistently >70% utilization
- Memory: Scale when >80% utilization
- Storage: Scale when >80% disk usage

## 📝 Documentation

- [Production Environment Details](infrastructure/environments/production/README.md)
- [Infrastructure Requirements](docs/dedicated-infrastructure-requirements.md)
- [VM Module Documentation](infrastructure/modules/vm/README.md)

## 🤝 Contributing

1. Create feature branch from `main`
2. Make changes and validate locally with `mise run check`
3. Push to trigger Scalr plan
4. Create PR for review
5. Merge triggers production deployment

## 📜 License

MIT License - See [LICENSE](LICENSE) file for details

## 🏷️ Tags & Labels

All resources are tagged with:
- `terraform` - IaC managed
- `vault` - Service identifier
- `production` - Environment
- `hercules` - Project name
- `vault-cluster` - Cluster identifier

## ⚠️ Important Notes

- **Automated provisioning**: Cloud-init handles all VM setup (Vault + QEMU agent)
- **Production-focused**: Single environment design for simplified deployment
- **nftables management**: External firewall control, no conflicting services
- Never commit `terraform.tfvars` with actual values
- Use `terraform.tfvars.example` as template
- Sensitive variables must be configured in Scalr
- State is managed remotely by Scalr
- VCS triggers defined in `scalr.yaml`

## 🔄 Migration Path

From existing Nomad cluster infrastructure:
1. Deploy new Vault VMs using this configuration
2. Migrate Vault data from lloyd/holly/mable
3. Update DNS and load balancer configurations
4. Decommission Vault from Nomad servers

---

**Workspace**: `production-vault` | **Backend**: Scalr Remote | **Provider**: Proxmox (bpg/proxmox)

![Visitor Badge](https://visitor-badge.laobi.icu/badge?page_id=basher83.Hercules-Vault-infra)
