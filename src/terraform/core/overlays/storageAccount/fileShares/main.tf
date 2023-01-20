# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#---------------------------------------------------------
# Resource Group Creation or selection - Default is "false"
#----------------------------------------------------------
data "azurerm_resource_group" "rgrp" {
  count = var.create_resource_group == false ? 1 : 0
  name  = var.resource_group_name
}

resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = lower(local.resource_group_name)
  location = local.location
  tags     = merge({ "ResourceName" = format("%s", local.resource_group_name) }, var.tags, )
}

#---------------------------------------------------------
# Storage Account Creation or selection 
#----------------------------------------------------------
module "storage" {
  source = "../../modules/Microsoft.Storage"

  # By default, this module will not create a resource group
  # provide a name to use an existing resource group, specify the existing resource group name,
  # and set the argument to `create_resource_group = false`. Location will be same as existing RG.
  resource_group_name  = local.resource_group_name
  location             = local.location
  storage_account_name = var.storage_account_name

  # To enable advanced threat protection set argument to `true`
  enable_advanced_threat_protection = var.enable_advanced_threat_protection

  # SMB file share with quota (GB) to create
  # Example: file_shares = [ { name = "fileshare1", quota = 1 }, { name = "fileshare2", quota = 2 } ]
  file_shares = var.file_shares

  # Configure managed identities to access Azure Storage (Optional)
  # Possible types are `SystemAssigned`, `UserAssigned` and `SystemAssigned, UserAssigned`.
  # managed_identity_type = "UserAssigned"

  # Adding TAG's to your Azure resources (Required)
  tags = var.tags

}
