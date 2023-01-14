# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

data "azurerm_client_config" "current" {}

module "management_groups" {
  source = "../../modules/Microsoft.Management/managementGroups"

  root_parent_id = data.azurerm_client_config.current.tenant_id
  root_id        = var.root_id
  root_name      = var.root_display_name
  landing_zones  = var.management_groups

  tags = merge(var.tags, {
    DeployedBy = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}



output "management_groups" {
  value = module.management_groups.management_groups
}
