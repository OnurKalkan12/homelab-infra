resource "proxmox_virtual_environment_container" "this" {
  node_name    = var.proxmox_node
  unprivileged = var.unprivileged
  started      = true
  start_on_boot = true

  cpu {
    cores = var.cores
  }

  memory {
    dedicated = var.memory
  }

  disk {
    datastore_id = var.datastore_id
    size         = var.disk_size
  }

  network_interface {
    name    = "eth0"
    bridge  = "vmbr1"
    vlan_id = var.vlan_tag
  }

  operating_system {
    template_file_id = var.os_template
    type             = "debian"
  }

  initialization {
    hostname = var.hostname

    ip_config {
      ipv4 {
        address = var.ip_address
        gateway = var.gateway
      }
    }

    user_account {
      keys = [trimspace(var.ssh_public_key)]
    }
  }

  features {
    nesting = true
  }
}
