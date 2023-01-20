# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# This module deploys a Public IP Address
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip

resource "azurerm_public_ip" "pip" {
  name                = var.public_ip_address_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.public_ip_address_allocation
  sku                 = var.public_ip_address_sku_name
  tags                = var.tags
}
