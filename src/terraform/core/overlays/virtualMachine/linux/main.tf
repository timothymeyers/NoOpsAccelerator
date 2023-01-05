# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

data "azurerm_resource_group" "vm_resource_group" {
  name = var.resource_group_name
}

resource "random_integer" "linux-vm-password" {
  min = 6
  max = 72
}

resource "random_password" "linux-vm-password" {
  length      = random_integer.linux-vm-password.result
  upper       = true
  lower       = true
  numeric     = true
  special     = true
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
  min_special = 1
}

module "mod_virtual_machine" {
  source = "../../../modules/Microsoft.Compute/linuxVirtualMachines"

  // Global Settings
  resource_group_name  = var.resource_group_name
  location             = var.location
  subnet_id            = var.subnet_id
  virtual_network_name = var.virtual_network_name

  // VM Settings
  name                            = var.vm_name
  size                            = var.size
  admin_username                  = var.admin_username
  admin_password                  = var.use_random_password ? random_password.linux-vm-password.result : var.admin_password
  disable_password_authentication = var.disable_password_authentication
  network_interface_name          = var.network_interface_name
  ip_configuration_name           = var.ip_configuration_name
  network_security_group_name     = var.network_security_group_name
  log_analytics_workspace_id      = var.log_analytics_workspace_id
  log_analytics_workspace_key     = var.log_analytics_workspace_key

  // OS Settings
  os_disk_image = var.vm_os_disk_image

  // key vault
  use_key_vault = var.use_key_vault

  // Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = "Linux VM"
  })
}





