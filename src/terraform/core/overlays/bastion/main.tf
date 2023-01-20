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

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}


data "azurerm_resource_group" "hub" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "hub_bastion_host_vnet" {
  name                = var.virtual_network_name
  resource_group_name = data.azurerm_resource_group.hub.name
}

module "bastion_subnet" {
  source = "../../modules/Microsoft.Network/subnets"

  // Global Settings
  location = var.location

  // Subnet Parameters
  resource_group_name  = data.azurerm_resource_group.hub.name
  virtual_network_name = data.azurerm_virtual_network.hub_bastion_host_vnet.name

  subnet_name                                   = "AzureBastionSubnet"
  address_prefixes                              = [cidrsubnet(var.bastion_address_space, 0, 0)]
  service_endpoints                             = var.bastion_subnet_service_endpoints
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = false
}

// NSG around the Azure Bastion Subnet. This is required for the Azure Bastion to work.
module "mod_bastion_host_nsg" {
  depends_on = [data.azurerm_resource_group.hub]
  source     = "../../modules/Microsoft.Network/networkSecurityGroups"

  // Global Settings  
  resource_group_name = data.azurerm_resource_group.hub.name
  location            = var.location

  // Network Security Group Settings
  name      = local.bastionHostNetworkSecurityGroupName  
}

resource "azurerm_subnet_network_security_group_association" "this" {
  subnet_id                 = module.bastion_subnet.id
  network_security_group_id = module.mod_bastion_host_nsg.network_security_group_id
}

module "mod_bastion_host" {
  depends_on = [data.azurerm_resource_group.hub]
  source     = "../../modules/Microsoft.Network/bastionHost"

  // Global Settings
  resource_group_name  = data.azurerm_resource_group.hub.name
  location             = data.azurerm_resource_group.hub.location
  virtual_network_name = data.azurerm_virtual_network.hub_bastion_host_vnet.name

  // Bastion Host Settings
  bastion_host_name            = local.bastionHostName
  bastion_host_sku_name        = "Standard"
  public_ip_address_name       = local.bastionHostPublicIPAddressName
  public_ip_address_sku_name   = local.bastionHostPublicIPAddressSkuName
  public_ip_address_allocation = local.bastionHostPublicIPAddressAllocationMethod
  ipconfig_name                = local.bastionNetworkInterfaceIpConfigurationName
  subnet_id                    = module.bastion_subnet.id

  // Bastion Resource Lock
  enable_resource_lock = var.enable_resource_lock
  lock_level           = var.lock_level

  // Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Azure Bastion Host: %s", local.bastionHostName)
  })
}

#
#
# Linux Jumpbox
#
#
module "mod_linux_jumpbox" {
  count = var.create_bastion_linux_jumpbox ? 1 : 0

  depends_on = [data.azurerm_resource_group.hub, module.mod_bastion_host]
  source     = "../virtualMachine/linux"

  // Global Settings
  resource_group_name  = data.azurerm_resource_group.hub.name
  location             = var.location
  virtual_network_name = data.azurerm_virtual_network.hub_bastion_host_vnet.name

  // Jumpbox Settings
  vm_name                     = local.linuxVmName
  subnet_id                   = var.vm_subnet_id
  network_interface_name      = local.linuxNetworkInterfaceName
  ip_configuration_name       = local.linuxNetworkInterfaceIpConfigurationName
  network_security_group_name = module.mod_bastion_host_nsg.network_security_group_name

  // OS Settings
  size           = var.size_linux_jumpbox
  admin_username = var.admin_username
  admin_password = var.use_random_password ? null : var.admin_password

  // OS Image Settings
  vm_os_disk_image = var.vm_os_linux_disk_image

  // key vault
  use_key_vault               = var.use_key_vault
  log_analytics_workspace_id  = var.log_analytics_workspace_id
  log_analytics_workspace_key = var.log_analytics_workspace_key

  // Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Linux VM for Azure Bastion %s", local.bastionHostName)
  })
}

#
#
# Windows Jumpbox
#
#
module "mod_windows_jumpbox" {
  count = var.create_bastion_windows_jumpbox ? 1 : 0

  depends_on = [data.azurerm_resource_group.hub, module.mod_bastion_host]
  source     = "../virtualMachine/windows"

  // Global Settings
  resource_group_name  = data.azurerm_resource_group.hub.name
  location             = var.location
  virtual_network_name = data.azurerm_virtual_network.hub_bastion_host_vnet.name

  // Jumpbox Settings
  vm_name                     = local.windowsVmName
  subnet_id                   = var.vm_subnet_id
  network_interface_name      = local.windowsNetworkInterfaceName
  ip_configuration_name       = local.windowsNetworkInterfaceIpConfigurationName
  network_security_group_name = module.mod_bastion_host_nsg.network_security_group_name

  // OS Settings
  size           = var.size_windows_jumpbox
  admin_username = var.admin_username
  admin_password = var.use_random_password ? null : var.admin_password

  // OS Image Settings
  vm_os_disk_image = var.vm_os_windows_disk_image

  // key vault
  use_key_vault               = var.use_key_vault
  log_analytics_workspace_id  = var.log_analytics_workspace_id
  log_analytics_workspace_key = var.log_analytics_workspace_key

  // Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Windows VM for Azure Bastion %s", local.bastionHostName)
  })
}
