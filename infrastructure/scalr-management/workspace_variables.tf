data "infisical_secrets" "scalr" {
  count        = var.infisical_project_id != "" ? 1 : 0
  workspace_id = var.infisical_project_id
  env_slug     = var.infisical_environment
  folder_path  = var.infisical_path_scalr
}

locals {
  from_infisical = var.infisical_project_id != ""
  # infisical_secrets returns a map where keys are secret names and values have .value, .comment, .secret_type
  secret_map          = local.from_infisical ? { for k, v in data.infisical_secrets.scalr[0].secrets : k => v.value } : {}
  pve_api_url_val     = local.from_infisical ? lookup(local.secret_map, "PROXMOX_OG_API_URL", var.og_homelab_api_url) : var.og_homelab_api_url
  pve_api_token_val   = local.from_infisical ? lookup(local.secret_map, "PROXMOX_OG_API_TOKEN", var.og_homelab_api_token) : var.og_homelab_api_token
  ci_ssh_key_test_val = local.from_infisical ? lookup(local.secret_map, "SSH_PUBLIC_KEY", var.test_ssh_public_key) : var.test_ssh_public_key
}

resource "scalr_variable" "test_api_url" {
  key          = "pve_api_url"
  value        = local.pve_api_url_val
  category     = "terraform"
  workspace_id = scalr_workspace.test_proxmox.id
  description  = "Proxmox API endpoint for og-homelab"
}

resource "scalr_variable" "test_api_token" {
  key          = "pve_api_token_og"
  value        = local.pve_api_token_val
  category     = "terraform"
  sensitive    = true
  workspace_id = scalr_workspace.test_proxmox.id
  description  = "Proxmox API token for og-homelab"
}

resource "scalr_variable" "test_ssh_key" {
  key          = "ci_ssh_key_test"
  value        = local.ci_ssh_key_test_val
  category     = "terraform"
  sensitive    = true
  workspace_id = scalr_workspace.test_proxmox.id
  description  = "SSH public key for test VMs"
}


