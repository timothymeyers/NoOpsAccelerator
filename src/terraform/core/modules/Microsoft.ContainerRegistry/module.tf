# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# This module deploys a container registry to the specified resource group.
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry


#############################################
# DATA                                      #
#############################################
data "azurerm_resource_group" "rg" {
    name = var.resource_group_name
}

##################################################
# RESOURCES                                      #
##################################################
resource "azurerm_container_registry" "acr" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  sku                      = var.sku
  admin_enabled            = var.admin_enabled
  tags                     = var.tags

  identity {
    type = "UserAssigned"
    identity_ids = [
      var.acr_identity_id
    ]
  }

  dynamic "georeplications" {
    for_each = var.georeplication_locations

    content {
      location = georeplications.value
      tags     = var.tags
    }
  }

  lifecycle {
      ignore_changes = [
          tags
      ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "settings" {
  name                       = "DiagnosticsSettings"
  target_resource_id         = azurerm_container_registry.acr.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  log {
    category = "ContainerRegistryRepositoryEvents"
    enabled  = true

    retention_policy {
      enabled = true
      days    = var.log_analytics_retention_days
    }
  }

  log {
    category = "ContainerRegistryLoginEvents"
    enabled  = true

    retention_policy {
      enabled = true
      days    = var.log_analytics_retention_days
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
      days    = var.log_analytics_retention_days
    }
  }
}
