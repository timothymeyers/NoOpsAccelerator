# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#-----------------------------------------------------------------------
# Subnets Creation for Azure Bastion Service - at least /27 or larger.
#-----------------------------------------------------------------------
resource "azurerm_subnet" "abs_snet" {
  count                = var.subnet_bastion_cidr != null ? 1 : 0
  name                 = "AzureBastionSubnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_bastion_cidr]
}