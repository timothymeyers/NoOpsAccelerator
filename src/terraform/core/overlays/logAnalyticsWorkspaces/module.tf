# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# This module deploys a Log Analytics Workspace
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace

##################################################
# RESOURCES                                      #
##################################################
resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  retention_in_days   = var.retention_in_days != "" ? var.retention_in_days : null
  daily_quota_gb      = var.daily_quota_gb != "" ? var.daily_quota_gb : null
  tags = merge(local.tags, {
    DeployedBy = format("AzureNoOpsTF [%s]", terraform.workspace)
  })

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

// Setup Log Analytics Solutions for Log Analytics Workspace
resource "azurerm_log_analytics_solution" "log_solutions" {
  for_each = { for solution in var.solution_plans : solution.solution_name => solution }

  solution_name         = try(each.value.solution_name, "solution_name", "")
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
  workspace_name        = azurerm_log_analytics_workspace.log_analytics_workspace.name

  plan {
    product   = try(each.value.product, "product", "")
    publisher = try(each.value.publisher, "publisher", "")
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
