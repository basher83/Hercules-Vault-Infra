# Vault Production Environment

This directory contains the Terraform configuration for deploying the production Vault cluster to Proxmox.

## Architecture

The production environment deploys a 4-VM Vault cluster:

- **1x Master Vault** (vault-master): Auto-unseal provider with Transit engine
  - 2 vCPU, 4GB RAM, 40GB SSD
  - Provides auto-unseal service to production nodes
  
- **3x Production Vault Nodes** (vault-prod-1/2/3): Raft cluster members
  - 4 vCPU, 8GB RAM, 100GB SSD each
  - High availability configuration with Raft consensus

## Scalr Integration

This environment is configured for Scalr VCS-driven workflow:

- **Workspace**: `vault-production`
- **Backend**: Remote state managed by Scalr
- **Auto-apply**: Disabled (manual approval required)
- **Trigger paths**: 
  - `infrastructure/environments/production/`
  - `infrastructure/modules/`

## Configuration

### Required Variables (Set in Scalr Workspace)

```hcl
pve_api_url       = "https://your-proxmox-host:8006/api2/json"
pve_api_token     = "user@pam!token-id=token-secret"
ci_ssh_key        = "ssh-ed25519 AAAA... your-key"
```

### Optional Variables

```hcl
vault_network_subnet = "192.168.10"  # Default network subnet
template_id         = 8000           # Ubuntu 22.04 template
vm_datastore        = "local-lvm"    # Storage location
vm_bridge_1         = "vmbr0"        # Network bridge
```

## Deployment

### Via Scalr (Recommended)

1. Push changes to your VCS repository
2. Scalr will automatically trigger a plan
3. Review the plan in Scalr UI
4. Apply the changes through Scalr

### Manual Deployment (Development Only)

```bash
# Initialize Terraform with Scalr backend
terraform init

# Plan changes
terraform plan

# Apply changes (will use Scalr backend)
terraform apply
```

## Network Configuration

| VM | IP Address | Role | Ports |
|---|---|---|---|
| vault-master | 192.168.10.30 | Auto-unseal Provider | 8200 (API) |
| vault-prod-1 | 192.168.10.31 | Production Node 1 | 8200 (API), 8201 (Raft) |
| vault-prod-2 | 192.168.10.32 | Production Node 2 | 8200 (API), 8201 (Raft) |
| vault-prod-3 | 192.168.10.33 | Production Node 3 | 8200 (API), 8201 (Raft) |

## High Availability

VMs are distributed across Proxmox nodes for fault tolerance:
- vault-master: lloyd
- vault-prod-1: holly
- vault-prod-2: mable
- vault-prod-3: lloyd

## Outputs

After deployment, Terraform provides:
- Individual VM details (IPs, IDs, node assignments)
- Vault API endpoints
- Ansible inventory for configuration management
- Cluster resource summary

## Security Notes

- All sensitive variables should be configured in Scalr workspace
- Never commit terraform.tfvars with actual values
- Use terraform.tfvars.example as a template
- Enable TLS for all Vault communications
- Configure firewall rules to restrict access to Vault ports

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0, < 2.0.0 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | ~> 0.73 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vm"></a> [vm](#module\_vm) | ../../modules/vm | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ci_ssh_key"></a> [ci\_ssh\_key](#input\_ci\_ssh\_key) | SSH public key for cloud-init | `string` | n/a | yes |
| <a name="input_cloud_init_username"></a> [cloud\_init\_username](#input\_cloud\_init\_username) | Username for cloud-init | `string` | `"ubuntu"` | no |
| <a name="input_proxmox_insecure"></a> [proxmox\_insecure](#input\_proxmox\_insecure) | Set true to skip TLS verification for Proxmox API (not recommended in production) | `bool` | `false` | no |
| <a name="input_pve_api_token"></a> [pve\_api\_token](#input\_pve\_api\_token) | Proxmox API token ID | `string` | n/a | yes |
| <a name="input_pve_api_url"></a> [pve\_api\_url](#input\_pve\_api\_url) | Proxmox API endpoint URL | `string` | n/a | yes |
| <a name="input_template_id"></a> [template\_id](#input\_template\_id) | Template ID for VM cloning | `number` | `8000` | no |
| <a name="input_vault_network_subnet"></a> [vault\_network\_subnet](#input\_vault\_network\_subnet) | Network subnet for Vault cluster (without last octet) | `string` | `"192.168.10"` | no |
| <a name="input_vm_bridge_1"></a> [vm\_bridge\_1](#input\_vm\_bridge\_1) | Primary network bridge for VMs | `string` | `"vmbr0"` | no |
| <a name="input_vm_datastore"></a> [vm\_datastore](#input\_vm\_datastore) | Proxmox datastore for VM disks | `string` | `"local-lvm"` | no |
| <a name="input_vm_tags"></a> [vm\_tags](#input\_vm\_tags) | Default tags for all VMs | `list(string)` | `["terraform", "vault", "production", "hercules"]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ansible_yaml_inventory"></a> [ansible\_yaml\_inventory](#output\_ansible\_yaml\_inventory) | Ansible inventory in YAML format for Vault cluster configuration |
| <a name="output_network_configuration"></a> [network\_configuration](#output\_network\_configuration) | Network configuration for the Vault cluster |
| <a name="output_vault_cluster_summary"></a> [vault\_cluster\_summary](#output\_vault\_cluster\_summary) | Vault cluster configuration summary |
| <a name="output_vault_master"></a> [vault\_master](#output\_vault\_master) | Master Vault VM details for auto-unseal provider |
| <a name="output_vault_production_nodes"></a> [vault\_production\_nodes](#output\_vault\_production\_nodes) | Production Vault cluster nodes details |
<!-- END_TF_DOCS -->