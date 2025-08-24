# Scalr Management

This directory manages Scalr workspaces, tags, and variables with Terraform.

## Files

- `versions.tf`, `providers.tf`: Provider and backend configuration
- `variables.tf`: Inputs (hostname, token, account, VCS, provider configs)
- `tags.tf`: Common tags
- `workspaces.tf`: Workspaces for `scalr-management`, `test-proxmox`, `staging-proxmox`
- `workspace_variables.tf`: Workspace-scoped variables for test workspace
- `outputs.tf`: Workspace IDs

## Bootstrap (local state)

1. Set environment variables or provide a `terraform.tfvars` with required inputs.
1. Init and create tags/workspace skeleton first:

```bash
cd infrastructure/scalr-management
terraform init -backend=false
terraform apply -target='scalr_tag.this["test"]' -target='scalr_tag.this["production"]' -target='scalr_tag.this["og-homelab"]' -target='scalr_tag.this["doggos-homelab"]'
terraform apply -target=scalr_workspace.scalr_management
```

1. Migrate backend to Scalr (adjust values):

```bash
terraform init -migrate-state \
  -backend-config="hostname=${SCALR_HOSTNAME}" \
  -backend-config="organization=${SCALR_ORG}" \
  -backend-config="workspaces={name=\"scalr-management\"}"
```

1. Apply fully:

```bash
terraform apply
```

## Required Inputs

- `scalr_hostname`, `scalr_token`, `scalr_account_id`
- `scalr_vcs_provider_id`, `repo_identifier`, `repo_branch`
- `proxmox_og_provider_config_id`, `proxmox_doggos_provider_config_id`
- Secrets for `workspace_variables.tf`: `og_homelab_api_token`, `test_ssh_public_key`

## Notes

- `iac_platform` is set to `terraform`. Change to `opentofu` if desired.
- `trigger_patterns_*` mirror the deployment plan.
- All secrets should be supplied via secure variable sets (Infisical/Scalr).

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
| <a name="requirement_infisical"></a> [infisical](#requirement\_infisical) | ~> 0.15.28 |
| <a name="requirement_scalr"></a> [scalr](#requirement\_scalr) | ~> 3.6 |
## Providers

| Name | Version |
|------|---------|
| <a name="provider_infisical"></a> [infisical](#provider\_infisical) | 0.15.31 |
| <a name="provider_scalr"></a> [scalr](#provider\_scalr) | 3.6.0 |
## Modules

No modules.
## Resources

| Name | Type |
|------|------|
| [scalr_tag.this](https://registry.terraform.io/providers/Scalr/scalr/latest/docs/resources/tag) | resource |
| [scalr_variable.test_api_token](https://registry.terraform.io/providers/Scalr/scalr/latest/docs/resources/variable) | resource |
| [scalr_variable.test_api_url](https://registry.terraform.io/providers/Scalr/scalr/latest/docs/resources/variable) | resource |
| [scalr_variable.test_ssh_key](https://registry.terraform.io/providers/Scalr/scalr/latest/docs/resources/variable) | resource |
| [scalr_workspace.scalr_management](https://registry.terraform.io/providers/Scalr/scalr/latest/docs/resources/workspace) | resource |
| [scalr_workspace.staging_proxmox](https://registry.terraform.io/providers/Scalr/scalr/latest/docs/resources/workspace) | resource |
| [scalr_workspace.test_proxmox](https://registry.terraform.io/providers/Scalr/scalr/latest/docs/resources/workspace) | resource |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_staging_workspace"></a> [enable\_staging\_workspace](#input\_enable\_staging\_workspace) | Whether to manage the staging workspace in this stack (disable to avoid trigger overlap with existing prod workspace) | `bool` | `false` | no |
| <a name="input_infisical_environment"></a> [infisical\_environment](#input\_infisical\_environment) | Infisical environment (e.g., dev, prod) | `string` | `"dev"` | no |
| <a name="input_infisical_path_scalr"></a> [infisical\_path\_scalr](#input\_infisical\_path\_scalr) | Infisical path for Scalr-related secrets | `string` | `"/scalr"` | no |
| <a name="input_infisical_project_id"></a> [infisical\_project\_id](#input\_infisical\_project\_id) | Infisical project ID to read secrets from | `string` | `"7b832220-24c0-45bc-a5f1-ce9794a31259"` | no |
| <a name="input_og_homelab_api_token"></a> [og\_homelab\_api\_token](#input\_og\_homelab\_api\_token) | API token for og-homelab Proxmox | `string` | `""` | no |
| <a name="input_og_homelab_api_url"></a> [og\_homelab\_api\_url](#input\_og\_homelab\_api\_url) | API URL for og-homelab Proxmox | `string` | `"https://192.168.30.30:8006/api2/json"` | no |
| <a name="input_proxmox_doggos_provider_config_id"></a> [proxmox\_doggos\_provider\_config\_id](#input\_proxmox\_doggos\_provider\_config\_id) | Provider configuration ID for doggos-homelab Proxmox (pcfg-xxxx...) | `string` | `"pcfg-v0ou0vcc8n9s42gbt"` | no |
| <a name="input_proxmox_og_provider_config_id"></a> [proxmox\_og\_provider\_config\_id](#input\_proxmox\_og\_provider\_config\_id) | Provider configuration ID for og-homelab Proxmox (pcfg-xxxx...) | `string` | `"pcfg-v0ou0ver2ujd0cct0"` | no |
| <a name="input_repo_branch"></a> [repo\_branch](#input\_repo\_branch) | VCS repository branch | `string` | `"main"` | no |
| <a name="input_repo_identifier"></a> [repo\_identifier](#input\_repo\_identifier) | VCS repository identifier (:org/:repo) | `string` | `"basher83/terraform-homelab"` | no |
| <a name="input_scalr_account_id"></a> [scalr\_account\_id](#input\_scalr\_account\_id) | Scalr account ID (acc-xxxx...) | `string` | n/a | yes |
| <a name="input_scalr_environment_name"></a> [scalr\_environment\_name](#input\_scalr\_environment\_name) | Scalr environment name to place workspaces in | `string` | `"development"` | no |
| <a name="input_scalr_hostname"></a> [scalr\_hostname](#input\_scalr\_hostname) | Scalr hostname (e.g., the-mothership.scalr.io) | `string` | n/a | yes |
| <a name="input_scalr_token"></a> [scalr\_token](#input\_scalr\_token) | Scalr service account token | `string` | n/a | yes |
| <a name="input_scalr_vcs_provider_id"></a> [scalr\_vcs\_provider\_id](#input\_scalr\_vcs\_provider\_id) | Scalr VCS provider ID (vcs-xxxx...) for GitHub/GitLab integration | `string` | n/a | yes |
| <a name="input_staging_workspace_name"></a> [staging\_workspace\_name](#input\_staging\_workspace\_name) | Name of the staging workspace | `string` | `"staging-proxmox"` | no |
| <a name="input_test_ssh_public_key"></a> [test\_ssh\_public\_key](#input\_test\_ssh\_public\_key) | SSH public key for test VMs | `string` | `""` | no |
| <a name="input_test_workspace_name"></a> [test\_workspace\_name](#input\_test\_workspace\_name) | Name of the test workspace | `string` | `"test-proxmox"` | no |
| <a name="input_trigger_patterns_staging"></a> [trigger\_patterns\_staging](#input\_trigger\_patterns\_staging) | Trigger patterns for staging workspace (gitignore-style) | `string` | `"/infrastructure/environments/staging/\n/infrastructure/modules/vm/\n"` | no |
| <a name="input_trigger_patterns_test"></a> [trigger\_patterns\_test](#input\_trigger\_patterns\_test) | Trigger patterns for test workspace (gitignore-style) | `string` | `"/infrastructure/environments/test/\n/infrastructure/modules/test-vm/\n"` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_scalr_management_workspace_id"></a> [scalr\_management\_workspace\_id](#output\_scalr\_management\_workspace\_id) | Workspace ID for scalr-management |
| <a name="output_staging_proxmox_workspace_id"></a> [staging\_proxmox\_workspace\_id](#output\_staging\_proxmox\_workspace\_id) | Workspace ID for staging-proxmox |
| <a name="output_test_proxmox_workspace_id"></a> [test\_proxmox\_workspace\_id](#output\_test\_proxmox\_workspace\_id) | Workspace ID for test-proxmox |
<!-- END_TF_DOCS -->
