# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

module "locks" {
  source = "../../Microsoft.Authorization/locks"
  count  = var.enable_resource_locks ? 1 : 0
  name   = "${azurerm_firewall.fw.name}-${var.lock_level}-lock"
  scope_id   = azurerm_firewall.fw.id
  lock_level = var.lock_level
}


