# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

output "bastion_subnet_id" {
  description = "Dedicated subnet id for the Bastion."
  value       = azurerm_subnet.abs_snet.0.id
}

output "bastion_id" {
  description = "Azure Bastion id."
  value       = azurerm_bastion_host.main.id
}

output "bastion_name" {
  description = "Azure Bastion name."
  value       = azurerm_bastion_host.main.name
}

output "bastion_fqdn" {
  description = "Azure Bastion FQDN / generated DNS name."
  value       = azurerm_bastion_host.main.dns_name
}

output "bastion_public_ip_name" {
  description = "Azure Bastion public IP resource name."
  value       = azurerm_public_ip.pip.name
}

output "bastion_public_ip" {
  description = "Azure Bastion public IP."
  value       = azurerm_public_ip.pip.ip_address
}