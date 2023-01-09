# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

// Spoke Network
module "mod_spoke_network" {
  source = "../../../../modules/Microsoft.Network/virtualNetworks"

  // Global Settings
  location = var.location

  // VNET Parameters
  vnet_name           = var.vnet_name
  vnet_address_space  = var.vnet_address_space
  resource_group_name = data.azurerm_resource_group.rg.name

  // VNET Resource Lock Parameters
  enable_resource_locks = var.enable_resource_locks
  lock_level           = var.lock_level

  // VNET Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Operations Network Resource: %s", var.vnet_name)
  }) # Tags to be applied to all resources
}

// Spoke logging storage account
module "mod_spoke_logging_storage" {
  source = "../../../../modules/Microsoft.Storage"

  //Global Settings
  location = var.location

  // Storage Account Parameters
  name                = var.log_storage_account_name
  resource_group_name = var.resource_group_name
  storage_account     = var.logging_storage_account_config

  // Storage Account Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("spoke Network Resource: %s", var.log_storage_account_name)
  }) # Tags to be applied to all resources
}
