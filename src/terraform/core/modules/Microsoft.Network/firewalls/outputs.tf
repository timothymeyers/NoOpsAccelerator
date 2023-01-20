# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

output "firewall_id" {
  description = "The ID of the Azure Firewall"
  value       = azurerm_firewall.fw.id
}

output "public_ip_prefix_id" {
  description = "The id of the Public IP Prefix resource"
  value       = azurerm_public_ip_prefix.fw-pref.id
}

output "firewall_public_ip" {
  description = "the public ip of firewall."
  value       = azurerm_firewall.fw.ip_configuration.0.public_ip_address_id
}

output "firewall_private_ip" {
  description = "The private ip of firewall."
  value       = azurerm_firewall.fw.ip_configuration.0.private_ip_address
}

output "firewall_name" {
  description = "The name of the Azure Firewall."
  value       = azurerm_firewall.fw.name
}

output "virtual_hub_private_ip_address" {
  description = "The private IP address associated with the Firewall"
  value       = var.virtual_hub != null ? azurerm_firewall.fw.virtual_hub.0.private_ip_address : null
}

output "virtual_hub_public_ip_addresses" {
  description = "The private IP address associated with the Firewall"
  value       = var.virtual_hub != null ? azurerm_firewall.fw.virtual_hub.0.public_ip_addresses : null
}