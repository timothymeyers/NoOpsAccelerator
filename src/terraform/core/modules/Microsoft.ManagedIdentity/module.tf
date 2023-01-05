# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# This module deploys a user assigned identity to the specified resource group.
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity

##################################################
# RESOURCES                                      #
##################################################
resource "azurerm_user_assigned_identity" "user_identity" {
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  name = "${var.name}Identity"

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
