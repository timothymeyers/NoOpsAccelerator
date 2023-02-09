# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "azurerm_network_security_group" "nsg" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags = merge(var.tags, {
    DeployedBy = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}

resource "azurerm_network_security_rule" "inbound" {
  for_each                    = { for rule in var.inbound_rules : rule.name => rule }
  resource_group_name         = azurerm_network_security_group.nsg.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
  direction                   = "Inbound"
  name                        = each.value.name
  priority                    = each.value.priority
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_address_prefixes     = lookup(each.value, "source_address_prefixes", "*")
  source_port_range           = lookup(each.value, "source_port_range", "*")
  destination_address_prefix  = lookup(each.value, "destination_address_prefix", "*")
  destination_port_ranges     = lookup(each.value, "destination_port_ranges", "*")
  description                 = lookup(each.value, "description", null)
}

resource "azurerm_network_security_rule" "outbound" {
  for_each                    = { for rule in var.outbound_rules : rule.name => rule }
  resource_group_name         = azurerm_network_security_group.nsg.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
  direction                   = "Outbound"
  name                        = each.value.name
  priority                    = each.value.priority
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_address_prefixes     = lookup(each.value, "source_address_prefixes", "*")
  source_port_range           = lookup(each.value, "source_port_range", "*")
  destination_address_prefix  = lookup(each.value, "destination_address_prefix", "*")
  destination_port_ranges     = lookup(each.value, "destination_port_ranges", "*")
  description                 = lookup(each.value, "description", null)
}
