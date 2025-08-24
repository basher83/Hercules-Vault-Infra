terraform {
  required_version = ">= 1.3.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.73"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "proxmox" {
  endpoint  = var.pve_api_url
  api_token = var.pve_api_token
  insecure  = var.proxmox_insecure

  # SSH connection for operations that require it (e.g., uploading files)
  ssh {
    agent       = var.ssh_private_key == "" ? true : false
    username    = var.proxmox_ssh_username
    private_key = var.ssh_private_key != "" ? var.ssh_private_key : null
  }
}
