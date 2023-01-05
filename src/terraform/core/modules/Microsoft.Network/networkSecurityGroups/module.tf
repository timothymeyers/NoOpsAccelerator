# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "azurerm_network_security_group" "nsg" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  lifecycle {
    ignore_changes = [
      tags
    ]
  }

  tags = merge(var.tags, {
    DeployedBy = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}

module "mod_nsg_rules" {
  source   = "./rule"
  for_each = var.nsg_rules

  location                   = var.location
  name                       = each.value.name
  priority                   = each.value.priority
  direction                  = each.value.direction
  access                     = each.value.access
  protocol                   = each.value.protocol
  source_port_range          = each.value.source_port_range
  destination_port_range     = each.value.destination_port_range
  source_address_prefix      = each.value.source_address_prefix
  destination_address_prefix = each.value.destination_address_prefix
  resource_group_name        = azurerm_network_security_group.nsg.resource_group_name
  nsg_id                     = azurerm_network_security_group.nsg.name
}

module "mod_nsg_diagnostics" {
  source = "../../Microsoft.Insights/diagnosticSettings"
  count  = var.enable_diagnostic_settings ? 1 : 0

  name                       = var.enable_diagnostic_settings ? "${var.name}-diagnostics" : ""
  target_resource_id         = azurerm_network_security_group.nsg.id
  storage_account_id         = var.log_analytics_storage_id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  logs                       = var.nsg_log_categories
  metrics                    = var.nsg_metric_categories
}
