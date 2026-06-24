variable "proxmox_node" {
  type        = string
  description = "Proxmox node name to create the VMs on"
}

variable "vault_ip" {
  type        = string
  description = "Intended static IP for CyberArk Vault (CIDR). Set manually during Windows setup."
}

variable "pvwa_ip" {
  type        = string
  description = "Intended static IP for CyberArk PVWA (CIDR). Set manually during Windows setup."
}

variable "cores" {
  type        = number
  description = "Number of vCPU cores per VM"
}

variable "memory" {
  type        = number
  description = "RAM in MB per VM"
}

variable "disk_size" {
  type        = number
  description = "Root disk size in GB per VM"
}

variable "vlan_tag" {
  type        = number
  description = "VLAN tag for both CyberArk VMs (40 — isolated, no internet egress)"
}

variable "windows_iso" {
  type        = string
  description = "Proxmox ISO file ID for Windows Server 2022, e.g. local:iso/windows-server-2022.iso"
}

variable "virtio_iso" {
  type        = string
  description = "Proxmox ISO file ID for VirtIO drivers, e.g. local:iso/virtio-win.iso"
  default     = "local:iso/virtio-win.iso"
}

variable "datastore_id" {
  type        = string
  description = "Proxmox storage pool for VM disks"
  default     = "local-lvm"
}
