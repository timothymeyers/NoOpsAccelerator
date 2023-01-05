# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "azurerm_subnet" "subnet" {
  for_each = { for subnet in var.subnets : subnet.name => subnet }

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = try(each.value.address_prefixes, "address_prefixes", [])
  service_endpoints    = try(each.value.service_endpoints, "service_endpoints", [])
  # `enforce_private_link_endpoint_network_policies` will be removed in favour of the property `private_endpoint_network_policies_enabled` in version 4.0 of the AzureRM Provider
  private_endpoint_network_policies_enabled     = try(each.value.enforce_private_link_endpoint_network_policies, "private_endpoint_network_policies_enabled", false)
  private_link_service_network_policies_enabled = try(each.value.enforce_private_link_service_network_policies, "private_link_service_network_policies_enabled", false)
}
