# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# This module deploys a Resource Group
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group

resource "azurerm_resource_group" "rg" {
  name     = var.name
  location = var.location
  tags = merge(local.tags, {
    DeployedBy = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}
