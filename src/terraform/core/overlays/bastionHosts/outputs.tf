# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

output "bastion_subnet_id" {
  description = "Dedicated subnet id for the Bastion."
  value       = module.subnet_bastion.subnet_id
}

output "bastion_id" {
  description = "Azure Bastion id."
  value       = azurerm_bastion_host.bastion.id
}

output "bastion_name" {
  description = "Azure Bastion name."
  value       = azurerm_bastion_host.bastion.name
}

output "bastion_fqdn" {
  description = "Azure Bastion FQDN / generated DNS name."
  value       = azurerm_bastion_host.bastion.dns_name
}

output "bastion_public_ip_name" {
  description = "Azure Bastion public IP resource name."
  value       = azurerm_public_ip.bastion_pubip.name
}

output "bastion_public_ip" {
  description = "Azure Bastion public IP."
  value       = azurerm_public_ip.bastion_pubip.ip_address
}