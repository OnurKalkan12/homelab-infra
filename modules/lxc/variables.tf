variable "proxmox_node" {
  type        = string
  description = "Proxmox node name to create the container on"
}

variable "hostname" {
  type        = string
  description = "Hostname of the container"
}

variable "ip_address" {
  type        = string
  description = "Static IP in CIDR notation, e.g. 192.168.30.10/24"
}

variable "gateway" {
  type        = string
  description = "Default gateway for the container's network segment"
}

variable "cores" {
  type        = number
  description = "Number of vCPU cores"
}

variable "memory" {
  type        = number
  description = "RAM in MB"
}

variable "disk_size" {
  type        = number
  description = "Root disk size in GB"
}

variable "vlan_tag" {
  type        = number
  description = "VLAN tag to attach the container to (e.g. 30 for workload)"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key injected at creation — used by Ansible to connect"
}

variable "os_template" {
  type        = string
  description = "Proxmox template file ID, e.g. local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
  default     = "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
}

variable "datastore_id" {
  type        = string
  description = "Proxmox storage pool for the container root disk"
  default     = "local-lvm"
}

variable "unprivileged" {
  type        = bool
  description = "Run as unprivileged container. Set to false for Docker support."
  default     = false
}
