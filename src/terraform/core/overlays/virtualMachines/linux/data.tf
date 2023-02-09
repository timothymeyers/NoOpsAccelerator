
# By default, this module will not create a resource group
# provide a name to use an existing resource group, specify the existing resource group name,
# and set the argument to `create_vm_resource_group = false`. Location will be same as existing RG.

#----------------------------------------------------------
# Resource Group, VNet, Subnet selection
#----------------------------------------------------------
resource "azurerm_resource_group" "rg" {
  count    = var.create_vm_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = merge({ "ResourceName" = format("%s", var.resource_group_name) }, var.tags, )
}

data "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "snet" {
  name                 = var.vm_subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = var.resource_group_name
}

data "azurerm_storage_account" "storeacc" {
  count               = var.enable_boot_diagnostics ? 1 : 0
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}
