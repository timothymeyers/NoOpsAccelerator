# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

module "locks" {
  source = "../Microsoft.Authorization/locks"
  count  = var.enable_resource_lock ? 1 : 0
  name   = "${azurerm_kubernetes_cluster.aks_cluster.name}-${var.lock_level}-lock"
  scope_id   = azurerm_kubernetes_cluster.aks_cluster.id
  lock_level = var.lock_level
}
