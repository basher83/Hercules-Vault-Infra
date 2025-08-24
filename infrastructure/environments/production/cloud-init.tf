# Cloud-init snippet file for Vault cluster VMs
resource "proxmox_virtual_environment_file" "vault_cloud_init" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "lloyd" # Primary Proxmox node for snippet storage

  source_raw {
    data = <<-EOF
    #cloud-config
    # Cloud-init configuration for Vault cluster VMs

    # Install required packages
    packages:
      - qemu-guest-agent
      - wget
      - gpg
      - curl
      - unzip
      - jq
      - net-tools
      - ca-certificates
      - gnupg
      - lsb-release
      - software-properties-common

    # Add HashiCorp repository and install Vault
    runcmd:
      # Start QEMU guest agent immediately
      - systemctl start qemu-guest-agent
      - systemctl enable qemu-guest-agent
      
      # Add HashiCorp GPG key and repository
      - wget -O - https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
      - echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
      
      # Update and install Vault
      - apt-get update
      - apt-get install -y vault
      
      # Create Vault data directory
      - mkdir -p /opt/vault/data
      - chown -R vault:vault /opt/vault
      
      # Set Vault to not start automatically (will configure first)
      - systemctl stop vault
      - systemctl disable vault
      
      # Disable other firewalls (nftables managed externally)
      - systemctl disable ufw || true
      - systemctl stop ufw || true
      - systemctl disable iptables || true
      - systemctl stop iptables || true
      
      # Set up Vault environment
      - echo 'export VAULT_ADDR="https://127.0.0.1:8200"' >> /etc/environment
      - echo 'export VAULT_SKIP_VERIFY="true"' >> /etc/environment
      
      # Log installation status
      - vault version || echo "Vault installation may have failed"
      - systemctl status qemu-guest-agent || echo "Guest agent not running"

    # Ensure services are enabled
    bootcmd:
      - [ cloud-init-per, once, qemu-guest-agent-start, systemctl, start, qemu-guest-agent ]

    # System configuration
    timezone: UTC
    locale: en_US.UTF-8

    # Disable swap for better Vault performance
    swap:
      filename: ""
      size: 0

    # Write Vault configuration files (to be customized per node later)
    write_files:
      - path: /etc/vault.d/vault.hcl
        owner: vault:vault
        permissions: '0640'
        content: |
          # Vault configuration
          # This is a placeholder - will be updated based on node role
          ui = true
          disable_mlock = true
          
          listener "tcp" {
            address       = "0.0.0.0:8200"
            tls_disable   = "true"  # Will be configured with proper TLS later
          }
          
          # Storage backend will be configured based on role:
          # - Master: Dev mode with Transit engine
          # - Production: Raft storage backend

      - path: /usr/local/bin/vault-health-check.sh
        owner: root:root
        permissions: '0755'
        content: |
          #!/bin/bash
          # Simple health check script for Vault
          curl -s -o /dev/null -w "%%{http_code}" http://127.0.0.1:8200/v1/sys/health | grep -E "^(200|429|473|501|503)$" > /dev/null
          exit $?

    # Final message
    final_message: "Vault VM initialization complete. Vault installed but not started. Configure based on node role (master/production)."
    EOF

    file_name = "vault-cloud-init.yaml"
  }
}