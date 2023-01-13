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

output "route_table_id" {
  description = "The id of the route table"
  value       = module.mod_spoke_subnets.route_table_id
}

output "storage_account_id" {
  description = "The id of the storage account"
  value       = module.mod_spoke_network.storage_account_id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = module.mod_spoke_network.storage_account_name
}

output "subnet_ids" {
  description = "Returns all the subnets ids in the Virtual Network. As a map of ID"
  value       = module.mod_spoke_subnets.subnet_ids
}
