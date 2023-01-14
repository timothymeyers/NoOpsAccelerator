# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

output "private_ip" {
  description = "Firewall Private IP Address."
  value       = module.mod_networking_hub_firewall.private_ip
}

output "public_ip" {
  description = "Firewall Public IP Address."
  value       = module.mod_networking_hub_firewall.public_ip
}

output "resource_group_name" {
  description = "The name of the resource group in which resources are created"
  value       = var.resource_group_name
}

output "virtual_network_name" {
  description = "The name of the virtual network"
  value       = module.mod_hub_network.virtual_network_name
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
  value       = module.mod_hub_network.storage_account_id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = module.mod_hub_network.storage_account_name
}

output "subnet_ids" {
  description = "Returns all the subnets ids in the Virtual Network. As a map of ID"
  value       = module.mod_hub_subnet.subnet_ids
}

output "network_security_group_id" {
  description = "The id of the network security group"
  value       = module.mod_hub_subnet.network_security_group_id
}

output "network_security_group_name" {
  description = "The name of the network security group"
  value       = module.mod_hub_subnet.network_security_group_name
}