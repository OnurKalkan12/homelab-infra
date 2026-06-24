resource "proxmox_network_linux_bridge" "vmbr1" {
  node_name  = var.proxmox_node
  name       = "vmbr1"
  comment    = "Internal VLAN-aware bridge — all homelab environments attach here"
  vlan_aware = true

  lifecycle {
    prevent_destroy = true
  }
}
