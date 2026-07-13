terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.66"   # adjust to the current release; tofu init + the lock file will pin it
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  insecure = true   # Proxmox self-signed cert
  # API token is read from the PROXMOX_VE_API_TOKEN environment variable — never committed
}