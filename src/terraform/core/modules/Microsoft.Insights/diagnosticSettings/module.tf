# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# This module deploys a diagnostic_setting to the specified resource group.
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting

##################################################
# RESOURCES                                      #
##################################################
resource "azurerm_monitor_diagnostic_setting" "settings" {
  count                          = var.enable_diagnostic_setting ? 1 : 0
  name                           = var.name
  target_resource_id             = var.target_resource_id

  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = var.log_analytics_destination_type

  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id

  storage_account_id             = var.storage_account_id

  dynamic "log" {
    for_each = var.logs
    content {
      category = log.value
      enabled  = true

      retention_policy {
        enabled = true
        days    = var.retention_policy_days
      }
    }
  }

  dynamic "metric" {
    for_each = var.metrics
    content {
      category = metric.value
      enabled  = true

      retention_policy {
        enabled = false
      }
    }
  }
}

