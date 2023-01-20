# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module to deploy the Logging based on the Azure Mission Landing Zone conceptual architecture
DESCRIPTION: The following components will be options in this deployment
              Log Analytics Workspace
              Log Storage
              Diagnostic Logging
AUTHOR/S: jrspinella
*/

###################################
### STAGE 1: Build out Logging  ###
###################################

module "mod_logging_storage_account" {
  source = "../../storageAccount"

  //Global Settings
  resource_group_name = var.resource_group_name
  location            = var.location

  // Storage Account Parameters
  storage_account_name = var.storage_account_name
  account_kind         = "StorageV2"
  sku_name             = "Standard_LRS"

  // Locks
  enable_resource_locks = var.enable_resource_locks
  lock_level            = var.lock_level

  // Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Operations Logging Resource: %s", var.storage_account_name)
  }) # Tags to be applied to all resources
}

output "storage_accounts" {
  value     = module.mod_logging_storage_account
  sensitive = true
}

module "laws" { # Log Analytics Workspace
  source = "../../../modules/Microsoft.OperationalInsights/workspaces"

  //Global Settings
  location = var.location

  // Log Analytics Workspace Parameters
  name                = var.log_analytics_workspace_name
  resource_group_name = var.resource_group_name
  sku                 = lookup(var.logging_log_analytics, "sku", "PerGB2018")
  retention_in_days   = lookup(var.logging_log_analytics, "retention_in_days", 30)
  daily_quota_gb      = lookup(var.logging_log_analytics, "daily_quota_gb", -1)

  // Log Analytics Workspace Solutions
  solution_plans = var.solution_plans

  // Log Analytics Workspace Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Operations Logging Resource: %s", var.log_analytics_workspace_name)
  }) # Tags to be applied to all resources

}

module "mod_law_sentinel" {
  depends_on = [module.laws]
  source     = "../../../modules/Microsoft.OperationsManagement/logAnalyticsWorkspaceSolutions"
  count      = var.deploy_sentinel ? 1 : 0

  //Global Settings
  location            = var.location
  resource_group_name = var.resource_group_name

  // Log Analytics Sentinel Parameters
  solution_name         = "SecurityInsights"
  product               = "OMSGallery/SecurityInsights"
  publisher             = "Microsoft"
  promotion_code        = null
  workspace_resource_id = module.laws.id
  workspace_name        = module.laws.name
}

