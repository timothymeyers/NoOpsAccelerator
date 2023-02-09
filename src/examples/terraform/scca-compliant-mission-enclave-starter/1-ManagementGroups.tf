# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module Example to deploy an Azure Management Group Hierarchy
DESCRIPTION: The following components will be options in this deployment
             * Management Group Hierarchy
AUTHOR/S: jspinella
*/

################################################
### STAGE 1: Management Group Configuations  ###
################################################

module "mod_management_group" {
  source            = "../../../terraform/core/overlays/managementGroups"
  root_id           = var.root_management_group_id
  root_parent_id    = data.azurerm_subscription.current_client.tenant_id
  root_name         = var.root_management_group_display_name
  management_groups = var.management_groups
}
