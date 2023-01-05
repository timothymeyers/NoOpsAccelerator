module "diagnostics" {
  source = "../Microsoft.Insights/diagnosticSettings"
  count  = var.enable_diagnostic_settings ? 1 : 0

  name                       = var.diagnostics_name
  target_resource_id         = azurerm_storage_account.storage_account.id
  storage_account_id         = var.log_analytics_storage_id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  logs                       = var.stg_log_categories
  metrics                    = var.stg_metric_categories
}

