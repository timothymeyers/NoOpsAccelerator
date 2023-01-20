# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# By default, this module will not create a resource group
# provide a name to use an existing resource group, specify the existing resource group name,
# and set the argument to `create_storage_account_resource_group = false`. Location will be same as existing RG.
resource "azurerm_resource_group" "rg" {
  count    = var.create_storage_account_resource_group ? 1 : 0
  name     = lower(var.resource_group_name)
  location = var.location
  tags     = merge({ "ResourceName" = format("%s", var.resource_group_name) }, var.tags, )
}

#---------------------------------------------------------
# Storage Account Creation or selection 
#----------------------------------------------------------
module "storage" {
  source = "../../modules/Microsoft.Storage"

  resource_group_name  = var.resource_group_name
  location             = var.location
  storage_account_name = var.storage_account_name
  account_kind         = var.account_kind
  sku_name             = var.sku_name

  # To enable advanced threat protection set argument to `true`
  enable_advanced_threat_protection = var.enable_advanced_threat_protection

  # Configure managed identities to access Azure Storage (Optional)
  # Possible types are `SystemAssigned`, `UserAssigned` and `SystemAssigned, UserAssigned`.
  # managed_identity_type = "UserAssigned"

  // Locks
  enable_resource_locks = var.enable_resource_locks
  lock_level            = var.lock_level

  # Adding TAG's to your Azure resources (Required)
  tags = var.tags

}
