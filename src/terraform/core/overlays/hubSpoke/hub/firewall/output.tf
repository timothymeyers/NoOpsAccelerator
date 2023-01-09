output "private_ip" {
  description = "Firewall Private IP Address."
  value       = module.mod_firewall.firewall_private_ip
}
