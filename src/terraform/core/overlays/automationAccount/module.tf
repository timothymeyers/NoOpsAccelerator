# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# This module deploys an automation account to the specified resource group.
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_account

resource "azurerm_automation_account" "auto_account" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tags                          = try(local.tags, {})
  public_network_access_enabled = try(var.public_network_access_enabled, null)
  sku_name                      = "Basic" #only Basic is supported at this time.

  dynamic "identity" {
    for_each = try(var.identity, null) == null ? [] : [1]

    content {
      type         = var.identity_type
      identity_ids = local.managed_identities
    }
  }
}
