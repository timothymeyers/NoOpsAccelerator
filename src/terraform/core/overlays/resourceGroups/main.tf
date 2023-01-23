# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
#---------------------------------------------------------------
# Resource Group Creation
#----------------------------------------------------------------

resource "azurerm_resource_group" "main_rg" {
  name     = local.rg_name
  location = var.location

  tags = merge(local.default_tags, var.extra_tags)
}
