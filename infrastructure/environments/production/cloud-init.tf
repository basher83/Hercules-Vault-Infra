# Cloud-init snippet file for Vault cluster VMs
resource "proxmox_virtual_environment_file" "vault_cloud_init" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "lloyd" # Primary Proxmox node for snippet storage

  source_raw {
    data = <<-EOF
    #cloud-config
    # Simplified cloud-init configuration for Vault cluster VMs
    # Focus on basic connectivity first

    # Install essential packages only
    packages:
      - qemu-guest-agent
      - curl
      - wget
      - openssh-server

    # Simple startup commands
    runcmd:
      # Ensure SSH is running
      - systemctl enable ssh
      - systemctl start ssh
      
      # Start and enable QEMU guest agent after package installation
      - systemctl enable qemu-guest-agent
      - systemctl start qemu-guest-agent
      
      # Log status for debugging
      - echo "Cloud-init completed at $(date)" >> /var/log/custom-init.log
      - systemctl status ssh >> /var/log/custom-init.log 2>&1
      - systemctl status qemu-guest-agent >> /var/log/custom-init.log 2>&1

    # System configuration
    timezone: UTC
    locale: en_US.UTF-8

    # Disable swap
    swap:
      filename: ""
      size: 0

    # Final message
    final_message: "Basic VM initialization complete. SSH and QEMU agent should be running."
    EOF

    file_name = "vault-cloud-init.yaml"
  }
}