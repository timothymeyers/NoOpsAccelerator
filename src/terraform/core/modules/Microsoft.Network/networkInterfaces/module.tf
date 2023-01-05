# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

data "azurerm_network_security_group" "nsg" {
  name                = var.network_security_group_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_interface" "nic" {
  name                          = var.network_interface_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  enable_accelerated_networking = var.enable_accelerated_networking

  ip_configuration {
    name                          = var.ip_configuration_name
    subnet_id                     = var.subnet_id
    public_ip_address_id          = try(var.public_ip_address_id, "")
    private_ip_address_allocation = var.private_ip_address_allocation
  }

  tags = merge(var.tags, {
    DeployedBy = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = data.azurerm_network_security_group.nsg.id
}
