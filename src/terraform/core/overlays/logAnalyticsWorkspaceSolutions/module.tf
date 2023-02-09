# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# This module deploys a Log Analytics Solution
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_solution

##################################################
# RESOURCES                                      #
##################################################
resource "azurerm_log_analytics_solution" "solution" {
  solution_name         = var.solution_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = var.workspace_resource_id
  workspace_name        = var.workspace_name
  tags                  = local.tags

  plan {
    publisher      = var.publisher
    product        = var.product
    promotion_code = var.promotion_code
  }
}
