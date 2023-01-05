# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

output "name" {
  description = "The Name of the Network Security Group"
  value       = azurerm_network_security_group.nsg.name
}

output "id" {
  description = "Specifies the resource id of the network security group"
  value       = azurerm_network_security_group.nsg.id
}
