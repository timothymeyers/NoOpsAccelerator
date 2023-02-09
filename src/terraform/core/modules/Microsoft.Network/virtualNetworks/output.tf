# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

output "resource_group_name" {
  description = "The name of the virtual network resource group"
  value       = azurerm_virtual_network.vnet.resource_group_name
}

output "resource_group_location" {
  description = "The name of the virtual network resource group location"
  value       = azurerm_virtual_network.vnet.location
}

output "virtual_network_name" {
  description = "The name of the virtual network"
  value       = element(concat(azurerm_virtual_network.vnet.*.name, [""]), 0)
}

output "virtual_network_id" {
  description = "The id of the virtual network"
  value       = element(concat(azurerm_virtual_network.vnet.*.id, [""]), 0)
}

output "virtual_network_address_space" {
  description = "List of address spaces that are used the virtual network."
  value       = element(coalescelist(azurerm_virtual_network.vnet.*.address_space, [""]), 0)
}

output "ddos_protection_plan" {
  description = "Ddos protection plan details"
  value       = var.create_ddos_plan ? element(concat(azurerm_network_ddos_protection_plan.ddos.*.id, [""]), 0) : null
}

output "network_watcher_id" {
  description = "ID of Network Watcher"
  value       = var.create_network_watcher != false ? element(concat(azurerm_network_watcher.nwatcher.*.id, [""]), 0) : null
}



