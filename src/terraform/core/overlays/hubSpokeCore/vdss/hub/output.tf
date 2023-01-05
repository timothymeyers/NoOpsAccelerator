# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

output "virtual_network_name" {
  description = "The name of the virtual network"
  value       = module.mod_hub_network.virtual_network_name
}

output "subnet_ids" {
  description = "The name of the resource group in which the virtual network is created."
  value       = module.mod_hub_subnet.subnet_ids
}

output "network_security_group_name" {
  description = "The name of the network security group in the virtual network subnet"
  value       = module.mod_hub_network_nsg.name
}

output "virtual_network_address_space" {
  description = "List of address spaces that are used the virtual network."
  value       = module.mod_hub_network.virtual_network_address_space
}

output "virtual_network_id" {
  description = "The id of the virtual network"
  value       = module.mod_hub_network.virtual_network_id
}

output "storage_account_id" {
  description = "The id of the storage account"
  value       = module.mod_hub_logging_storage.id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = module.mod_hub_logging_storage.name
}

output "log_analytics_storage_id" {
  description = "Log Analytics Storage ID."
  value       = module.mod_hub_logging_storage.id
}
