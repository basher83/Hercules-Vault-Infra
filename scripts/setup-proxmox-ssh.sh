#!/bin/bash
set -euo pipefail

# Setup SSH authentication for Proxmox hosts
# This script configures SSH keys for Terraform to upload files to Proxmox

echo "=== Proxmox SSH Setup for Terraform ==="
echo

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Proxmox host IPs (based on your infrastructure)
PROXMOX_HOSTS=(
    "192.168.10.2"  # holly
    "192.168.10.3"  # mable
    "192.168.10.4"  # lloyd
)

# Check if SSH key exists
SSH_KEY_PATH="${HOME}/.ssh/id_rsa"
if [ ! -f "${SSH_KEY_PATH}" ]; then
    echo -e "${YELLOW}SSH key not found at ${SSH_KEY_PATH}${NC}"
    echo "Would you like to generate a new SSH key? (y/n)"
    read -r response
    if [[ "$response" == "y" || "$response" == "Y" ]]; then
        ssh-keygen -t rsa -b 4096 -C "terraform-proxmox" -f "${SSH_KEY_PATH}"
        echo -e "${GREEN}SSH key generated successfully${NC}"
    else
        echo -e "${RED}SSH key is required for Terraform to upload files to Proxmox${NC}"
        echo "Please generate an SSH key or specify an existing one"
        exit 1
    fi
fi

# Start ssh-agent if not running
if ! pgrep -x ssh-agent > /dev/null; then
    echo "Starting ssh-agent..."
    eval "$(ssh-agent -s)"
fi

# Add SSH key to agent
echo "Adding SSH key to ssh-agent..."
ssh-add "${SSH_KEY_PATH}" 2>/dev/null || {
    echo -e "${YELLOW}Note: If prompted, enter your SSH key passphrase${NC}"
    ssh-add "${SSH_KEY_PATH}"
}

# Verify key is loaded
if ssh-add -L | grep -q "$(cat ${SSH_KEY_PATH}.pub)"; then
    echo -e "${GREEN}SSH key successfully loaded in ssh-agent${NC}"
else
    echo -e "${RED}Failed to load SSH key in ssh-agent${NC}"
    exit 1
fi

echo
echo "=== Copying SSH keys to Proxmox hosts ==="
echo "You will be prompted for the root password for each host"
echo

# Copy SSH key to each Proxmox host
for host in "${PROXMOX_HOSTS[@]}"; do
    echo -e "${YELLOW}Configuring SSH for ${host}...${NC}"
    
    # Test if we already have passwordless SSH access
    if ssh -o BatchMode=yes -o ConnectTimeout=5 root@"${host}" echo "SSH OK" 2>/dev/null; then
        echo -e "${GREEN}✓ SSH already configured for ${host}${NC}"
    else
        # Try to copy SSH key
        if ssh-copy-id -i "${SSH_KEY_PATH}.pub" root@"${host}" 2>/dev/null; then
            echo -e "${GREEN}✓ SSH key copied to ${host}${NC}"
        else
            echo -e "${RED}✗ Failed to copy SSH key to ${host}${NC}"
            echo "  Please ensure:"
            echo "  1. The host is reachable"
            echo "  2. SSH is enabled on the host"
            echo "  3. You have the correct root password"
        fi
    fi
done

echo
echo "=== Testing SSH connectivity ==="
echo

# Test SSH connectivity
all_success=true
for host in "${PROXMOX_HOSTS[@]}"; do
    echo -n "Testing ${host}... "
    if ssh -o BatchMode=yes -o ConnectTimeout=5 root@"${host}" echo "SSH connection successful" 2>/dev/null; then
        echo -e "${GREEN}✓ Success${NC}"
    else
        echo -e "${RED}✗ Failed${NC}"
        all_success=false
    fi
done

echo
if [ "$all_success" = true ]; then
    echo -e "${GREEN}=== SSH setup complete! ===${NC}"
    echo
    echo "Terraform can now upload files to your Proxmox hosts."
    echo
    echo "Next steps:"
    echo "1. Ensure your terraform.tfvars has the correct Proxmox API credentials"
    echo "2. Run 'terraform init' if you haven't already"
    echo "3. Run 'terraform plan' to verify the configuration"
    echo "4. Run 'terraform apply' to deploy the infrastructure"
else
    echo -e "${YELLOW}=== SSH setup partially complete ===${NC}"
    echo
    echo "Some hosts could not be configured. Please:"
    echo "1. Verify the host IPs are correct"
    echo "2. Ensure SSH is enabled on all Proxmox hosts"
    echo "3. Manually copy your SSH key to the failed hosts:"
    echo "   ssh-copy-id root@<host-ip>"
    echo
    echo "Once all hosts are configured, run 'terraform apply' to deploy."
fi

echo
echo "SSH Agent Status:"
ssh-add -l