# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

output "firewall_public_ip" {
  description = "The public ip of firewall."
  value       = module.mod_firewall_client_publicIP_address.ip_address
}

output "firewall_private_ip" {
  description = "The private ip of firewall."
  value       = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
}

output "name" {
  description = "The name of the firewall"
  value       = azurerm_firewall.firewall.name
}

output "id" {
  description = "The name of the firewall"
  value       = azurerm_firewall.firewall.id
}
