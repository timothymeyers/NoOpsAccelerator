# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

output "management_groups" {
  value = module.mod_management_group.management_groups
}

output "firewall_private_ip_address" {
  description = "The Firewall Private IP Address"
  value       = module.mod_hub_network.firewall_private_ip
}

output "firewall_public_ip_address" {
  description = "The Firewall Public IP Address"
  value       = module.mod_hub_network.firewall_public_ip
}

output "hub_subid" {
  description = "Subscription ID where the Hub Resource Group is provisioned"
  value       = var.hub_subscription_id
}

output "hub_rgname" {
  description = "The Hub Resource Group name"
  value       = module.mod_hub_network.resource_group_name
}

output "hub_vnetname" {
  description = "The Hub Virtual Network name"
  value       = module.mod_hub_network.virtual_network_name
}

output "ops_subid" {
  description = "Subscription ID where the Tier 1 Resource Group is provisioned"
  value       = coalesce(var.ops_subscription_id, var.hub_subscription_id)
}

output "svcs_subid" {
  description = "Subscription ID where the Tier 2 Resource Group is provisioned"
  value       = coalesce(var.svcs_subscription_id, var.hub_subscription_id)
}

output "laws_name" {
  description = "LAWS Name"
  value       = module.mod_operational_logging.laws_name
}

output "laws_rgname" {
  description = "Resource Group for Laws"
  value       = module.mod_operational_logging.laws_rgname
}

output "laws_resource_id" {
  description = "LAWS Name"
  value       = module.mod_operational_logging.laws_resource_id
}

output "laws_storage_account_id" {
  description = "LAWS Name"
  value       = module.mod_operational_logging.laws_StorageAccount_Id
}
