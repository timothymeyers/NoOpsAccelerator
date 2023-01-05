# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "azurerm_route_table" "routetable" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  disable_bgp_route_propagation = var.disable_bgp_route_propagation
  tags                          = var.tags
}

resource "azurerm_subnet_route_table_association" "subnet_association" {
  for_each = var.subnets_to_associate

  subnet_id      = "/subscriptions/${each.value.subscription_id}/resourceGroups/${each.value.resource_group_name}/providers/Microsoft.Network/virtualNetworks/${each.value.virtual_network_name}/subnets/${each.key}"
  route_table_id = azurerm_route_table.routetable.id
}
