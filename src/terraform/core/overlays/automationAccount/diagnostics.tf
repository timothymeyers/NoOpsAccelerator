# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "azurerm_monitor_diagnostic_setting" "settings" {
  count                          = var.enable_diagnostic_settings ? 1 : 0
  name                           = var.diagnostics_name
  target_resource_id             = azurerm_automation_account.auto_account.id

  log_analytics_workspace_id     = var.log_analytics_workspace_id 

  storage_account_id             = var.log_analytics_storage_resource_id

  dynamic "log" {
    for_each = var.auto_log_categories
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
    for_each = var.auto_metric_categories
    content {
      category = metric.value
      enabled  = true

      retention_policy {
        enabled = false
      }
    }
  }
}

