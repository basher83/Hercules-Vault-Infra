#!/bin/bash
set -euo pipefail

# Post-deployment script to install Vault and QEMU guest agent on VMs
# Run this after Terraform creates the VMs

echo "=== Vault Cluster Post-Deployment Setup ==="
echo

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# VM IPs
declare -A VM_IPS=(
    ["vault-master"]="192.168.10.30"
    ["vault-prod-1"]="192.168.10.31"
    ["vault-prod-2"]="192.168.10.32"
    ["vault-prod-3"]="192.168.10.33"
)

# Installation script
INSTALL_SCRIPT='#!/bin/bash
set -euo pipefail

echo "Installing QEMU guest agent and Vault..."

# Install QEMU guest agent
apt-get update
apt-get install -y qemu-guest-agent
systemctl enable qemu-guest-agent
systemctl start qemu-guest-agent

# Install required packages
apt-get install -y wget gpg curl unzip jq net-tools ca-certificates gnupg lsb-release software-properties-common ufw

# Add HashiCorp GPG key and repository
wget -O - https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list

# Update and install Vault
apt-get update
apt-get install -y vault

# Create Vault data directory
mkdir -p /opt/vault/data
chown -R vault:vault /opt/vault

# Set Vault to not start automatically (will configure first)
systemctl stop vault
systemctl disable vault

# Configure UFW firewall
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 8200/tcp  # Vault API
ufw allow 8201/tcp  # Vault Raft
echo "y" | ufw enable

# Set up Vault environment
echo "export VAULT_ADDR=\"https://127.0.0.1:8200\"" >> /etc/environment
echo "export VAULT_SKIP_VERIFY=\"true\"" >> /etc/environment

# Create basic Vault configuration
cat > /etc/vault.d/vault.hcl <<EOF
# Vault configuration
ui = true
disable_mlock = true

listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_disable   = "true"  # Will be configured with proper TLS later
}

# Storage backend will be configured based on role:
# - Master: Dev mode with Transit engine
# - Production: Raft storage backend
EOF

# Create health check script
cat > /usr/local/bin/vault-health-check.sh <<EOF
#!/bin/bash
curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8200/v1/sys/health | grep -E "^(200|429|473|501|503)$" > /dev/null
exit \$?
EOF
chmod +x /usr/local/bin/vault-health-check.sh

echo "Installation complete!"
'

# Function to install on a VM
install_on_vm() {
    local vm_name=$1
    local vm_ip=$2
    
    echo -e "${YELLOW}Setting up ${vm_name} (${vm_ip})...${NC}"
    
    # Test SSH connectivity
    if ! ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no ubuntu@"${vm_ip}" echo "SSH OK" 2>/dev/null; then
        echo -e "${RED}✗ Cannot connect to ${vm_name} at ${vm_ip}${NC}"
        echo "  Please ensure:"
        echo "  1. The VM is running"
        echo "  2. SSH is enabled"
        echo "  3. Your SSH key is authorized"
        return 1
    fi
    
    # Copy and run installation script
    echo "$INSTALL_SCRIPT" | ssh -o StrictHostKeyChecking=no ubuntu@"${vm_ip}" "sudo bash -s" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ ${vm_name} setup complete${NC}"
        return 0
    else
        echo -e "${RED}✗ ${vm_name} setup failed${NC}"
        return 1
    fi
}

# Main execution
echo "Starting post-deployment setup..."
echo

all_success=true
for vm_name in "${!VM_IPS[@]}"; do
    install_on_vm "$vm_name" "${VM_IPS[$vm_name]}" || all_success=false
    echo
done

if [ "$all_success" = true ]; then
    echo -e "${GREEN}=== Setup Complete ===${NC}"
    echo
    echo "All VMs have been configured with:"
    echo "• QEMU guest agent (running)"
    echo "• HashiCorp Vault (installed but not started)"
    echo "• UFW firewall (configured)"
    echo "• Basic Vault configuration"
    echo
    echo "Next steps:"
    echo "1. Configure Vault master node for auto-unseal"
    echo "2. Initialize Vault production cluster with Raft storage"
    echo "3. Configure auto-unseal from master to production nodes"
else
    echo -e "${YELLOW}=== Setup Partially Complete ===${NC}"
    echo
    echo "Some VMs could not be configured. Please check:"
    echo "1. VM connectivity"
    echo "2. SSH access"
    echo "3. Network configuration"
    echo
    echo "You can re-run this script after fixing any issues."
fi