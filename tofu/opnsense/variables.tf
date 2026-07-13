variable "proxmox_endpoint" {
  description = "Proxmox API endpoint of the node hosting OPNsense"
  type        = string
  default     = "https://10.0.10.11:8006/"   # dede
}

variable "target_node" {
  description = "Proxmox node to create the VM on"
  type        = string
  default     = "dede"
}

variable "opnsense_iso" {
  description = "Volume ID of the OPNsense installer ISO"
  type        = string
  default     = "rick-nfs:iso/OPNsense-26.1.6-dvd-amd64.iso"
}

variable "vm_datastore" {
  description = "Datastore for the OPNsense VM disk"
  type        = string
  default     = "local-lvm" 
}