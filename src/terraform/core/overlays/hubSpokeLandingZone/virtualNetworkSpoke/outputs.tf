
output "resource_group_name" {
  description = "The name of the virtual network"
  value       = module.mod_vnet.resource_group_name
}

output "virtual_network_name" {
  description = "The name of the virtual network"
  value       = module.mod_vnet.virtual_network_name
}

output "virtual_network_id" {
  description = "The id of the virtual network"
  value       = module.mod_vnet.virtual_network_id
}

output "virtual_network_address_space" {
  description = "List of address spaces that are used the virtual network."
  value       = module.mod_vnet.virtual_network_address_space
}

output "default_subnet_id" {
  description = "The id of the default subnet"
  value       = module.mod_default_snet.id
}

output "ddos_protection_plan" {
  description = "Ddos protection plan details"
  value       = module.mod_vnet.ddos_protection_plan
}

output "network_watcher_id" {
  description = "ID of Network Watcher"
  value       = module.mod_vnet.network_watcher_id
}


