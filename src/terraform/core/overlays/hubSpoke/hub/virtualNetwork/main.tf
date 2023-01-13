# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

// This module deploys the Hub Network and the Hub Logging Storage Account

// Hub Network
module "mod_network" {
  source = "../../../../modules/Microsoft.Network/virtualNetworks"

  // Global Settings
  location = var.location

  // VNET Parameters
  vnet_name           = var.vnet_name
  vnet_address_space  = var.vnet_address_space
  resource_group_name = var.resource_group_name

  // VNET Resource Lock Parameters
  enable_resource_locks = var.enable_resource_locks
  lock_level            = var.lock_level

  // VNET Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Hub Network Resource: %s", var.vnet_name)
  }) # Tags to be applied to all resources
}

// Hub logging storage account
module "mod_logging_storage" {
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
    description = format("Hub Network Resource: %s", var.log_storage_account_name)
  }) # Tags to be applied to all resources
}
