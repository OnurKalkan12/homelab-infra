output "vault_ip" {
  description = "Intended IP for CyberArk Vault (set manually during Windows setup)"
  value       = split("/", var.vault_ip)[0]
}

output "pvwa_ip" {
  description = "Intended IP for CyberArk PVWA (set manually during Windows setup)"
  value       = split("/", var.pvwa_ip)[0]
}
