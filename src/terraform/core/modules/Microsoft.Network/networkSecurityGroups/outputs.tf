# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Network Security group ids
output "network_security_group_id" {
  description = "List of Network security groups and ids"
  value       = azurerm_network_security_group.nsg.id
}

# Network Security group ids
output "network_security_group_name" {
  description = "List of Network security groups and names"
  value       = azurerm_network_security_group.nsg.name
}

output "inbound_rules" {
  value       = { for rule in azurerm_network_security_rule.inbound : rule.name => rule }
  description = "Blocks containing configuration of each inbound security rule."
  /*module.MODULE_NAME.inbound_rules["INBOUND_RULE_NAME"].id*/
}

output "outbound_rules" {
  value       = { for rule in azurerm_network_security_rule.outbound : rule.name => rule }
  description = "Blocks containing configuration of each outbound security rule."
  /*module.MODULE_NAME.outbound_rules["OUTBOUND_RULE_NAME"].id*/
}