data "scalr_environment" "main" {
  name       = var.scalr_environment_name
  account_id = var.scalr_account_id
}

resource "scalr_workspace" "scalr_management" {
  name              = "scalr-management"
  environment_id    = data.scalr_environment.main.id
  iac_platform      = "terraform"
  execution_mode    = "remote"
  auto_apply        = false
  working_directory = "infrastructure/scalr-management"

  vcs_provider_id = var.scalr_vcs_provider_id
  vcs_repo {
    identifier = var.repo_identifier
    branch     = var.repo_branch
    trigger_prefixes = [
      "infrastructure/scalr-management"
    ]
  }

  type    = "development"
  tag_ids = [scalr_tag.this["test"].id]
}

resource "scalr_workspace" "test_proxmox" {
  name              = var.test_workspace_name
  environment_id    = data.scalr_environment.main.id
  iac_platform      = "terraform"
  execution_mode    = "remote"
  auto_apply        = false
  working_directory = "infrastructure/environments/test"

  vcs_provider_id = var.scalr_vcs_provider_id
  vcs_repo {
    identifier = var.repo_identifier
    branch     = var.repo_branch
    trigger_prefixes = [
      "infrastructure/environments/test",
      "infrastructure/modules/vm"
    ]
  }

  provider_configuration {
    id = var.proxmox_og_provider_config_id
  }

  type    = "testing"
  tag_ids = [scalr_tag.this["test"].id, scalr_tag.this["og-homelab"].id]
}

resource "scalr_workspace" "staging_proxmox" {
  count                       = var.enable_staging_workspace ? 1 : 0
  name                        = var.staging_workspace_name
  environment_id              = data.scalr_environment.main.id
  iac_platform                = "terraform"
  execution_mode              = "remote"
  auto_apply                  = false
  deletion_protection_enabled = true
  working_directory           = "infrastructure/environments/staging"

  vcs_provider_id = var.scalr_vcs_provider_id
  vcs_repo {
    identifier = var.repo_identifier
    branch     = var.repo_branch
    trigger_prefixes = [
      "infrastructure/environments/staging",
      "infrastructure/modules/vm"
    ]
  }

  provider_configuration {
    id = var.proxmox_doggos_provider_config_id
  }

  type    = "staging"
  tag_ids = [scalr_tag.this["production"].id, scalr_tag.this["doggos-homelab"].id]
}


