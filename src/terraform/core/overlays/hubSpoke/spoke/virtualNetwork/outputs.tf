# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

output "resource_group_name" {
  description = "The name of the resource group in which resources are created"
  value       = var.resource_group_name
}

output "virtual_network_name" {
  description = "The name of the virtual network"
  value       = module.mod_spoke_network.virtual_network_name
}

output "virtual_network_address_space" {
  description = "List of address spaces that are used the virtual network."
  value       = module.mod_spoke_network.virtual_network_address_space
}

output "virtual_network_id" {
  description = "The id of the virtual network"
  value       = module.mod_spoke_network.virtual_network_id
}

output "storage_account_id" {
  description = "The id of the storage account"
  value       = module.mod_spoke_logging_storage.id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = module.mod_spoke_logging_storage.name
}
