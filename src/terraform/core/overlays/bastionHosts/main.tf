# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module to deploy a Bastion Host with Windows/Linux Jump Boxes to the Hub Network
DESCRIPTION: The following components will be options in this deployment
              Bastion Host
              Windows VM
              Lunix VM
AUTHOR/S: jspinella
*/

#----------------------------------------------------------
# Random Resources
#----------------------------------------------------------

resource "random_string" "str" {
  length  = 6
  special = false
  upper   = false
  keepers = {
    domain_name_label = coalesce(var.custom_bastion_name, data.azurenoopsutils_resource_name.bastion.result)
  }
}

#---------------------------------------------
# Public IP for Azure Bastion Service
#---------------------------------------------
resource "azurerm_public_ip" "pip" {
  name                = local.bastion_pip_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = var.public_ip_allocation_method
  sku                 = var.public_ip_sku # Mandatory for Azure Bastion host is Standard
  domain_name_label   = var.domain_name_label != null ? var.domain_name_label : format("gw%s%s", lower(replace(coalesce(var.custom_bastion_name, data.azurenoopsutils_resource_name.bastion.result), "/[[:^alnum:]]/", "")), random_string.str.result)
  zones               = var.public_ip_zones

  tags = merge(local.default_tags, var.extra_tags)

  lifecycle {
    ignore_changes = [
      tags,
      ip_tags,
    ]
  }
}

#---------------------------------------------
# Azure Bastion Service host
#---------------------------------------------
resource "azurerm_bastion_host" "main" {
  name                   = local.bastion_name
  location               = data.azurerm_resource_group.rg.location
  resource_group_name    = data.azurerm_resource_group.rg.name
  copy_paste_enabled     = var.enable_copy_paste
  file_copy_enabled      = var.bastion_sku == "Standard" ? var.enable_file_copy : null
  sku                    = var.bastion_sku
  ip_connect_enabled     = var.bastion_sku == "Standard" ? var.enable_ip_connect : null
  scale_units            = var.scale_units
  shareable_link_enabled = var.bastion_sku == "Standard" ? var.enable_shareable_link : null
  tunneling_enabled      = var.bastion_sku == "Standard" ? var.enable_tunneling : null
  tags                   = merge({ "ResourceName" = lower(coalesce(var.custom_bastion_name, data.azurenoopsutils_resource_name.bastion.result)) }, var.tags, )

  ip_configuration {
    name                 = "${lower(coalesce(var.custom_bastion_name, data.azurenoopsutils_resource_name.bastion.result))}-network"
    subnet_id            = azurerm_subnet.abs_snet.0.id
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}
