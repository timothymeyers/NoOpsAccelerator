output "resource_group_name" {
  description = "The name of the resource group in which resources are created"
  value       = module.mod_spoke_resource_group.name
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
  value       = module.mod_spoke_network.storage_account_id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = module.mod_spoke_network.storage_account_name
}

output "subnets" {
  description = "Returns all the subnets objects in the Virtual Network. As a map of keys, ID"
  value       = merge(var.spoke_subnets, module.mod_spoke_subnets)
}
