# DHCP Migration Guide

## Overview

This guide explains how to switch from static IP assignment to DHCP for the Vault cluster VMs.

## Current Static IP Setup

Currently, IPs are statically assigned via cloud-init:
- vault-master: 192.168.10.10
- vault-prod-1: 192.168.10.21
- vault-prod-2: 192.168.10.22
- vault-prod-3: 192.168.10.23

## Migration Options

### Option 1: Pure DHCP (Simple but Less Predictable)

**Pros:**
- Simple code changes
- No IP management needed
- Easy VM additions

**Cons:**
- IPs may change on reboot
- Requires DNS for service discovery
- Complicates Ansible inventory

**Implementation:**
1. Modify `infrastructure/modules/vm/main.tf`:
```hcl
ip_config {
  ipv4 {
    dhcp = true
  }
}
```

2. Remove IP variables from `infrastructure/environments/production/main.tf`

3. Update outputs to use detected IPs from QEMU guest agent

### Option 2: DHCP with MAC-based Reservations (Recommended)

**Pros:**
- Predictable IPs
- Central IP management in DHCP server
- Easier network changes
- Works with existing Ansible

**Cons:**
- Requires DHCP server configuration
- Need to manage MAC addresses

**Implementation:**

1. Add MAC address support to VM module:
```hcl
# In variables.tf
variable "mac_address" {
  description = "MAC address for primary network interface"
  type        = string
  default     = ""
}

# In main.tf
network_device {
  bridge      = var.vm_bridge_1
  mac_address = var.mac_address != "" ? var.mac_address : null
}
```

2. Define MAC addresses in production environment:
```hcl
locals {
  vm_instances = {
    vault-master = {
      name        = "vault-master"
      mac_address = "52:54:00:10:00:10"  # Maps to .10
      # ... rest of config
    }
    vault-prod-1 = {
      name        = "vault-master"
      mac_address = "52:54:00:10:00:21"  # Maps to .21
      # ... rest of config
    }
  }
}
```

3. Configure DHCP server (example for ISC DHCP):
```
host vault-master {
  hardware ethernet 52:54:00:10:00:10;
  fixed-address 192.168.10.10;
}

host vault-prod-1 {
  hardware ethernet 52:54:00:10:00:21;
  fixed-address 192.168.10.21;
}
# ... etc
```

### Option 3: Hybrid Approach (Flexible)

Support both DHCP and static via a variable:

```hcl
variable "ip_assignment" {
  description = "IP assignment method"
  type        = string
  default     = "static"
  validation {
    condition     = contains(["static", "dhcp"], var.ip_assignment)
    error_message = "Must be 'static' or 'dhcp'"
  }
}
```

## Impact Analysis

### Code Changes Required:

1. **Minimal Changes (Option 1):**
   - 1 line change in VM module
   - Remove IP variables
   - Update outputs

2. **Moderate Changes (Option 2):**
   - Add MAC address support
   - Configure DHCP server
   - Keep predictable IPs

3. **Most Flexible (Option 3):**
   - Add conditional logic
   - Support both modes
   - More complex but versatile

### What Stays the Same:

- VM provisioning process
- Scalr integration
- Resource specifications
- Network bridges
- SSH access

### What Changes:

- IP assignment method
- Network configuration in cloud-init
- Possibly Ansible inventory generation
- Monitoring configuration

## Recommendation

**For production**: Use Option 2 (DHCP with reservations)
- Keeps predictable IPs
- Central management
- Easier network changes

**For development/test**: Use Option 1 (Pure DHCP)
- Simple setup
- Quick provisioning
- No IP management

## Quick Test

To test DHCP without committing:

1. Create a test environment copy
2. Modify just the ip_config block:
```hcl
ip_config {
  ipv4 {
    dhcp = true
  }
}
```
3. Deploy one test VM
4. Verify DHCP assignment works
5. Check QEMU guest agent reports IP correctly