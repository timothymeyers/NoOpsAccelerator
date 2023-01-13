# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

output "firewall_private_ip_address" {
  description = "The Firewall Private IP Address"
  value       = module.mod_hub_network.private_ip
}

output "hub_subid" {
  description = "Subscription ID where the Hub Resource Group is provisioned"
  value       = var.hub_subscription_id
}

output "hub_resource_group_resource_id" {
  description = "The Hub Resource Group id"
  value       = module.mod_hub_resource_group.id
}

output "hub_rgname" {
  description = "The Hub Resource Group name"
  value       = module.mod_hub_resource_group.name
}

output "hub_vnetname" {
  description = "The Hub Virtual Network name"
  value       = module.mod_hub_network.virtual_network_name
}

output "hub_vnet_id" {
  description = "The Hub Virtual Network name"
  value       = module.mod_hub_network.virtual_network_id
}

/* output "ops_subid" {
  description = "Subscription ID where the Operations Resource Group is provisioned"
  value       = coalesce(var.ops_subid, var.hub_subid)
}

output "ops_vnetname" {
  description = "The Operations Virtual Network name"
  value       = module.mod_ops_network.virtual_network_name
}

/* output "ops_snetids" {
  description = "The Operations Virtual Network Subnet ids"
  value       = module.mod_ops_network.subnet_ids
}

output "svcs_subid" {
  description = "Subscription ID where the Shared Services Resource Group is provisioned"
  value       = coalesce(var.svcs_subid, var.hub_subid)
}

output "svcs_vnetname" {
  description = "The Shared Services Virtual Network name"
  value       = module.mod_svcs_network.virtual_network_name
}

/* output "svcs_snetids" {
  description = "The Shared Services Virtual Network Subnet ids"
  value       = module.mod_svcs_network.subnet_ids
} */

output "laws_resource_id" {
  description = "LAWS Resource ID"
  value       = module.mod_logging.laws_resource_id
}

output "laws_name" {
  description = "LAWS Name"
  value       = module.mod_logging.laws_name
}

output "laws_rgname" {
  description = "Resource Group for Laws"
  value       = module.mod_logging.laws_rgname
}

output "laws_storage_account_id" {
  description = "LAWS Name"
  value       = module.mod_logging.laws_StorageAccount_Id
}
