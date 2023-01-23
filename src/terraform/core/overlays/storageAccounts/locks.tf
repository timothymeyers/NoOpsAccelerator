# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#------------------------------------------------------------
# Resource Group Lock configuration - Default (required). 
#------------------------------------------------------------
resource "azurerm_management_lock" "resource_group_level_lock" {
  count      = var.enable_resource_locks ? 1 : 0
  name       = "${local.sa_name}-${var.lock_level}-lock"
  scope      = azurerm_storage_account.storage.id
  lock_level = var.lock_level
  notes      = "Storage Account '${local.sa_name}' is locked with '${var.lock_level}' level."
}
