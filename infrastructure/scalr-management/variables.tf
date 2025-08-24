variable "scalr_hostname" {
  description = "Scalr hostname (e.g., the-mothership.scalr.io)"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9.-]+$", var.scalr_hostname)) && !can(regex("^https?://", var.scalr_hostname))
    error_message = "Provide the hostname only (no scheme), e.g., the-mothership.scalr.io."
  }
}

variable "scalr_token" {
  description = "Scalr service account token"
  type        = string
  sensitive   = true
  validation {
    condition     = length(trimspace(var.scalr_token)) > 0
    error_message = "scalr_token must be non-empty."
  }
}

variable "scalr_account_id" {
  description = "Scalr account ID (acc-xxxx...)"
  type        = string
  validation {
    condition     = can(regex("^acc-[A-Za-z0-9]+$", var.scalr_account_id))
    error_message = "scalr_account_id must start with 'acc-' followed by alphanumeric characters."
  }
}

variable "scalr_environment_name" {
  description = "Scalr environment name to place workspaces in"
  type        = string
  default     = "development"
}

variable "scalr_vcs_provider_id" {
  description = "Scalr VCS provider ID (vcs-xxxx...) for GitHub/GitLab integration"
  type        = string
  # Remove default - should be provided via tfvars or environment
}

variable "repo_identifier" {
  description = "VCS repository identifier (:org/:repo)"
  type        = string
  default     = "basher83/terraform-homelab"
}

variable "repo_branch" {
  description = "VCS repository branch"
  type        = string
  default     = "main"
}

variable "trigger_patterns_test" {
  description = "Trigger patterns for test workspace (gitignore-style)"
  type        = string
  default     = <<-EOT
    /infrastructure/environments/test/
    /infrastructure/modules/test-vm/
  EOT
}

variable "trigger_patterns_staging" {
  description = "Trigger patterns for staging workspace (gitignore-style)"
  type        = string
  default     = <<-EOT
    /infrastructure/environments/staging/
    /infrastructure/modules/vm/
  EOT
}

variable "test_workspace_name" {
  description = "Name of the test workspace"
  type        = string
  default     = "test-proxmox"
}

variable "staging_workspace_name" {
  description = "Name of the staging workspace"
  type        = string
  default     = "staging-proxmox"
}

variable "enable_staging_workspace" {
  description = "Whether to manage the staging workspace in this stack (disable to avoid trigger overlap with existing prod workspace)"
  type        = bool
  default     = false
}

variable "proxmox_og_provider_config_id" {
  description = "Provider configuration ID for og-homelab Proxmox (pcfg-xxxx...)"
  type        = string
  default     = "pcfg-v0ou0ver2ujd0cct0"
}

variable "proxmox_doggos_provider_config_id" {
  description = "Provider configuration ID for doggos-homelab Proxmox (pcfg-xxxx...)"
  type        = string
  default     = "pcfg-v0ou0vcc8n9s42gbt"
}

variable "og_homelab_api_token" {
  description = "API token for og-homelab Proxmox"
  type        = string
  sensitive   = true
  default     = ""
}

variable "og_homelab_api_url" {
  description = "API URL for og-homelab Proxmox"
  type        = string
  default     = "https://192.168.30.30:8006/api2/json"
}

variable "test_ssh_public_key" {
  description = "SSH public key for test VMs"
  type        = string
  sensitive   = true
  default     = ""
}

# --- Infisical (Machine Identity) ---
# Authentication now handled via environment variables:
# INFISICAL_UNIVERSAL_AUTH_CLIENT_ID
# INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET

variable "infisical_project_id" {
  description = "Infisical project ID to read secrets from"
  type        = string
  default     = "7b832220-24c0-45bc-a5f1-ce9794a31259"
}

variable "infisical_environment" {
  description = "Infisical environment (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "infisical_path_scalr" {
  description = "Infisical path for Scalr-related secrets"
  type        = string
  default     = "/scalr"
}


