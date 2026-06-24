output "observability_ip" {
  description = "IP of the observability LXC. Paste this into ansible/inventory/hosts.yml after apply."
  value       = one(module.observability[*].ip_address)
}

output "cyberark_vault_ip" {
  description = "IP of the CyberArk Vault VM. Use for RDP and Ansible inventory."
  value       = one(module.cyberark[*].vault_ip)
}

output "cyberark_pvwa_ip" {
  description = "IP of the CyberArk PVWA VM. Open https://<ip>/PasswordVault in a browser."
  value       = one(module.cyberark[*].pvwa_ip)
}
