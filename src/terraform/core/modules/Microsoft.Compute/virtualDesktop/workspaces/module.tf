# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# This module deploys a virtual desktop workspace to the specified resource group.
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_desktop_workspace

resource "azurerm_virtual_desktop_workspace" "wvdws" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  friendly_name = try(var.friendly_name, null)
  description   = try(var.description, null)
  tags          = local.tags
}

