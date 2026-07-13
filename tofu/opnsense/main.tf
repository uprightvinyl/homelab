resource "proxmox_virtual_environment_vm" "opnsense" {
  name      = "opnsense"
  node_name = var.target_node
  tags      = ["opnsense", "opentofu"]

  cpu {
    cores = 2
    type  = "host"
  }
  memory {
    dedicated = 4096
  }

  disk {
    datastore_id = var.vm_datastore
    interface    = "virtio0"
    size         = 32
  }

  cdrom {
    file_id = var.opnsense_iso
  }

# LAN — VLAN 10
  network_device {
    bridge      = "vmbr0"
    mac_address = "BC:24:11:00:00:10"
  }

  # WAN — VLAN 4
  network_device {
    bridge      = "vmbr0"
    vlan_id     = 4
    mac_address = "BC:24:11:00:00:04"
  }

  operating_system {
    type = "other"   # FreeBSD-based
  }

  # Boot from the ISO for the install; we'll switch to the disk after
  boot_order = ["virtio0"]
}