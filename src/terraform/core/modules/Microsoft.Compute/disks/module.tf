# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# This module deploys a Managed Disk
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk

##################################################
# RESOURCES                                      #
##################################################
resource "azurerm_managed_disk" "vm_data_disk" {
  name                 = var.name
  location             = var.location
  resource_group_name  = var.resource_group_name
  create_option        = try(var.create_option, "Empty")
  disk_size_gb         = try(var.disk_size_gb, null)
  storage_account_type = try(var.storage_account_type, "Standard_LRS")
  source_uri           = try(var.source_uri, null)
  source_resource_id   = try(var.source_resource_id, null)
}
