
output "resource_group_name" {
  description = "The name of the virtual network resource group"
  value       = module.mod_vnet.resource_group_name
}

output "resource_group_location" {
  description = "The name of the virtual network resource group location"
  value       = module.mod_vnet.resource_group_location
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

output "nsg_id" {
  description = "The id of the virtual network"
  value       = module.mod_nsg.network_security_group_id
}

output "nsg_name" {
  description = "The id of the virtual network"
  value       = module.mod_nsg.network_security_group_name
}

output "default_subnet_id" {
  description = "The id of the default subnet"
  value       = module.mod_default_snet.id
}

output "default_subnet_name" {
  description = "The id of the default subnet"
  value       = module.mod_default_snet.name
}

output "ddos_protection_plan" {
  description = "Ddos protection plan details"
  value       = module.mod_vnet.ddos_protection_plan
}

output "network_watcher_id" {
  description = "ID of Network Watcher"
  value       = module.mod_vnet.network_watcher_id
}

output "firewall_id" {
  description = "The ID of the Azure Firewall"
  value       = module.mod_fw.0.firewall_id
}

output "public_ip_prefix_id" {
  description = "The id of the Public IP Prefix resource"
  value       = module.mod_fw.0.public_ip_prefix_id
}

output "firewall_public_ip" {
  description = "the public ip of firewall."
  value       = module.mod_fw.0.firewall_public_ip
}

output "firewall_private_ip" {
  description = "The private ip of firewall."
  value       = module.mod_fw.0.firewall_private_ip
}

output "firewall_name" {
  description = "The name of the Azure Firewall."
  value       = module.mod_fw.0.firewall_name
}