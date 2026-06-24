# ─── Proxmox connection ────────────────────────────────────────────────────────

variable "proxmox_endpoint" {
  type        = string
  description = "Proxmox API URL, e.g. https://192.168.10.1:8006/"
}

variable "proxmox_api_token" {
  type        = string
  description = "Proxmox API token. Format: user@realm!token_name=secret"
  sensitive   = true
}

variable "proxmox_node" {
  type        = string
  description = "Name of the Proxmox node to deploy resources on"
  default     = "pve"
}

# ─── SSH ───────────────────────────────────────────────────────────────────────

variable "ssh_public_key" {
  type        = string
  description = "SSH public key injected into every Linux container. Allows Ansible to connect without a password."
}

# ─── Environment toggles ───────────────────────────────────────────────────────

variable "create_observability" {
  type        = bool
  description = "Set to true to provision the observability LXC container"
  default     = false
}

variable "create_cyberark" {
  type        = bool
  description = "Set to true to provision the CyberArk Vault and PVWA VMs"
  default     = false
}

# ─── Observability environment ─────────────────────────────────────────────────

variable "observability_hostname" {
  type        = string
  description = "Hostname for the observability LXC container"
  default     = "obs01"
}

variable "observability_ip" {
  type        = string
  description = "Static IP address for the observability container (CIDR notation), e.g. 192.168.30.10/24"
  default     = "192.168.30.10/24"
}

variable "observability_gateway" {
  type        = string
  description = "Default gateway for VLAN 30"
  default     = "192.168.30.1"
}

variable "observability_cores" {
  type        = number
  description = "Number of vCPUs for the observability container"
  default     = 2
}

variable "observability_memory" {
  type        = number
  description = "RAM in MB for the observability container"
  default     = 3072
}

variable "observability_disk" {
  type        = number
  description = "Root disk size in GB for the observability container"
  default     = 30
}

# ─── Observability — OS template ──────────────────────────────────────────────

variable "observability_os_template" {
  type        = string
  description = "Proxmox LXC template file ID for the observability container"
  default     = "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
}

# ─── CyberArk environment ──────────────────────────────────────────────────────

variable "cyberark_vault_ip" {
  type        = string
  description = "Static IP for the CyberArk Vault VM (CIDR notation)"
  default     = "192.168.40.10/24"
}

variable "cyberark_pvwa_ip" {
  type        = string
  description = "Static IP for the CyberArk PVWA VM (CIDR notation)"
  default     = "192.168.40.11/24"
}

variable "cyberark_cores" {
  type        = number
  description = "Number of vCPUs per CyberArk VM"
  default     = 2
}

variable "cyberark_memory" {
  type        = number
  description = "RAM in MB per CyberArk VM"
  default     = 4096
}

variable "cyberark_disk" {
  type        = number
  description = "Root disk size in GB per CyberArk VM"
  default     = 60
}

variable "windows_iso" {
  type        = string
  description = "Proxmox ISO file ID for Windows Server 2022. Only required when create_cyberark = true."
  default     = ""
}

variable "virtio_iso" {
  type        = string
  description = "Proxmox ISO file ID for VirtIO drivers. Only required when create_cyberark = true."
  default     = "local:iso/virtio-win.iso"
}
