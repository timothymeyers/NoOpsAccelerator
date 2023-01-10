# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

output "management_groups" {
  value = module.mod_management_group.management_groups
}

output "firewall_private_ip_address" {
  description = "The Firewall Private IP Address"
  value       = module.mod_landingzone_hub2spoke.firewall_private_ip_address
}

output "hub_subid" {
  description = "Subscription ID where the Hub Resource Group is provisioned"
  value       = var.hub_subid
}

output "hub_rgname" {
  description = "The Hub Resource Group name"
  value       = module.mod_landingzone_hub2spoke.hub_rgname
}

output "hub_vnetname" {
  description = "The Hub Virtual Network name"
  value       = module.mod_landingzone_hub2spoke.hub_vnetname
}

output "ops_subid" {
  description = "Subscription ID where the Tier 1 Resource Group is provisioned"
  value       = coalesce(var.ops_subid, var.hub_subid)
}

output "svcs_subid" {
  description = "Subscription ID where the Tier 2 Resource Group is provisioned"
  value       = coalesce(var.svcs_subid, var.hub_subid)
}

output "laws_name" {
  description = "LAWS Name"
  value       = module.mod_landingzone_hub2spoke.laws_name
}

output "laws_rgname" {
  description = "Resource Group for Laws"
  value       = module.mod_landingzone_hub2spoke.laws_rgname
}

output "laws_resource_id" {
  description = "LAWS Name"
  value       = module.mod_landingzone_hub2spoke.laws_resource_id
}

output "laws_storage_account_id" {
  description = "LAWS Name"
  value       = module.mod_landingzone_hub2spoke.laws_storage_account_id
}
