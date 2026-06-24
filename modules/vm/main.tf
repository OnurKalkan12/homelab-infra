# CyberArk Vault VM
# Static IP (var.vault_ip) is configured manually during Windows Server setup.
# Windows does not support cloud-init — Terraform provisions the shell only.

resource "proxmox_virtual_environment_vm" "ca_vault" {
  node_name = var.proxmox_node
  name      = "ca-vault"
  on_boot   = true
  started   = true

  cpu {
    cores = var.cores
    type  = "host"
  }

  memory {
    dedicated = var.memory
  }

  disk {
    datastore_id = var.datastore_id
    interface    = "scsi0"
    size         = var.disk_size
    file_format  = "raw"
  }

  # Windows Server 2022 installation ISO.
  # VirtIO drivers ISO: attach manually via Proxmox UI (ide3) before starting.
  cdrom {
    file_id   = var.windows_iso
    interface = "ide2"
  }

  network_device {
    bridge  = "vmbr1"
    vlan_id = var.vlan_tag
    model   = "virtio"
  }

  operating_system {
    type = "win11"
  }
}

# CyberArk PVWA VM
# Requires IIS — installed via ansible/playbooks/cyberark-prep.yml after Windows setup.

resource "proxmox_virtual_environment_vm" "ca_pvwa" {
  node_name = var.proxmox_node
  name      = "ca-pvwa"
  on_boot   = true
  started   = true

  cpu {
    cores = var.cores
    type  = "host"
  }

  memory {
    dedicated = var.memory
  }

  disk {
    datastore_id = var.datastore_id
    interface    = "scsi0"
    size         = var.disk_size
    file_format  = "raw"
  }

  cdrom {
    file_id   = var.windows_iso
    interface = "ide2"
  }

  network_device {
    bridge  = "vmbr1"
    vlan_id = var.vlan_tag
    model   = "virtio"
  }

  operating_system {
    type = "win11"
  }
}
