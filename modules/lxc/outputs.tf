output "ip_address" {
  description = "IP address of the container (without subnet mask)"
  value       = split("/", var.ip_address)[0]
}
