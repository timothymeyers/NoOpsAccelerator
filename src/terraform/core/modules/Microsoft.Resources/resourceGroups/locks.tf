# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

module "locks" {
  source = "../../Microsoft.Authorization/locks"
  count  = var.enable_resource_lock ? 1 : 0
  name   = "${azurerm_resource_group.rg.name}-${var.lock_level}-lock"
  scope_id   = azurerm_resource_group.rg.id
  lock_level = var.lock_level
}


