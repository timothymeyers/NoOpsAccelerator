output "virtual_network_name" {
  description = "The name of the virtual network"
  value       = module.mod_ops_network.virtual_network_name
}

output "virtual_network_address_space" {
  description = "List of address spaces that are used the virtual network."
  value       = module.mod_ops_network.virtual_network_address_space
}

output "virtual_network_id" {
  description = "The id of the virtual network"
  value       = module.mod_ops_network.virtual_network_id
}

output "storage_account_id" {
  description = "The id of the storage account"
  value       = module.mod_ops_logging_storage.id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = module.mod_ops_logging_storage.name
}

output subnet_ids {
 description = "Contains a list of the the resource id of the subnets"
  value       = module.mod_workload_subnet.subnet_ids
}
