# ─── Network ───────────────────────────────────────────────────────────────────
# vmbr1 is the internal VLAN-aware bridge all environments attach to.
# This module is always included so the bridge exists before any environment
# is provisioned. prevent_destroy in the module protects it from terraform destroy.

module "network" {
  source = "./modules/network"

  proxmox_node = var.proxmox_node
}

# ─── Observability environment ─────────────────────────────────────────────────
# Enabled by setting create_observability = true in the active .tfvars file.
# count = 0 means the module is declared but no resources are created.

module "observability" {
  count  = var.create_observability ? 1 : 0
  source = "./modules/lxc"

  proxmox_node = var.proxmox_node
  hostname     = var.observability_hostname
  ip_address   = var.observability_ip
  gateway      = var.observability_gateway
  cores        = var.observability_cores
  memory       = var.observability_memory
  disk_size    = var.observability_disk
  vlan_tag       = 30
  ssh_public_key = var.ssh_public_key
  os_template    = var.observability_os_template

  depends_on = [module.network]
}

# ─── CyberArk PAM environment ──────────────────────────────────────────────────
# Enabled by setting create_cyberark = true in the active .tfvars file.
# Provisions two Windows Server VMs on isolated VLAN 40.

module "cyberark" {
  count  = var.create_cyberark ? 1 : 0
  source = "./modules/vm"

  proxmox_node   = var.proxmox_node
  vault_ip       = var.cyberark_vault_ip
  pvwa_ip        = var.cyberark_pvwa_ip
  cores          = var.cyberark_cores
  memory         = var.cyberark_memory
  disk_size      = var.cyberark_disk
  vlan_tag       = 40
  windows_iso    = var.windows_iso
  virtio_iso     = var.virtio_iso

  depends_on = [module.network]
}
