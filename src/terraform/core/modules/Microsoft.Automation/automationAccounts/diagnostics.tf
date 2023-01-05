# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

module "diagnostics" {
  source = "../../Microsoft.Insights/diagnosticSettings"
  count  = var.enable_diagnostic_settings == false ? 0 : 1

  name                       = var.diagnostics_name
  target_resource_id         = azurerm_automation_account.auto_account.id
  storage_account_id         = var.log_analytics_storage_resource_id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  logs                       = var.auto_log_categories
  metrics                    = var.auto_metric_categories
}
