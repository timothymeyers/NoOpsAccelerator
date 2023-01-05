# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# This module deploys a Public IP Address
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip

resource "azurerm_public_ip" "pip" {
  name                = var.public_ip_address_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.public_ip_address_allocation
  sku                 = var.public_ip_address_sku_name
  tags                = var.tags
}

// Setup Log Analytics for Public IP
module "mod_pip_diagnostics" {
  source = "../../Microsoft.Insights/diagnosticSettings"
  count  = var.enable_diagnostic_settings ? 1 : 0

  name                       = var.enable_diagnostic_settings ? "${var.public_ip_address_name}-diagnostics" : ""
  target_resource_id         = azurerm_public_ip.pip.id
  storage_account_id         = var.log_analytics_storage_resource_id
  log_analytics_workspace_id = var.log_analytics_workspace_resource_id
  logs                       = var.pip_log_categories
  metrics                    = var.pip_metric_categories
}