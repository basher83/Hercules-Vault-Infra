output "scalr_management_workspace_id" {
  description = "Workspace ID for scalr-management"
  value       = scalr_workspace.scalr_management.id
}

output "test_proxmox_workspace_id" {
  description = "Workspace ID for test-proxmox"
  value       = scalr_workspace.test_proxmox.id
}

output "staging_proxmox_workspace_id" {
  description = "Workspace ID for staging-proxmox"
  value       = var.enable_staging_workspace ? scalr_workspace.staging_proxmox[0].id : null
}
