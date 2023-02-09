##################################################
# RESOURCES                                      #
##################################################
resource "azurerm_management_lock" "resource_group_level_lock" {
  count      = var.enable_resource_locks ? 1 : 0
  name       = "${var.name}-${var.lock_level}-lock"
  scope      = var.scope_id
  lock_level = var.lock_level
  notes      = var.lock_level == "CanNotDelete" ? "Cannot delete resource or child resources." : "Cannot modify the resource or child resources."
}