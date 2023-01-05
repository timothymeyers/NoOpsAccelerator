# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# This module deploys a Windows Virtual Machine
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine

##################################################
# DATA                                           #
##################################################
data "azurerm_key_vault_secret" "pwd_key" {
  count        = var.use_key_vault == true ? 1 : 0
  name         = var.pwd_name
  key_vault_id = var.key_vault_id
}

data "azurerm_resource_group" "vm_resource_group" {
  name = var.resource_group_name
}

##################################################
# MODULES                                        #
##################################################
module "mod_virtual_machine_nic" {
  source                      = "../../Microsoft.Network/networkInterfaces"
  network_interface_name      = var.network_interface_name
  resource_group_name         = var.resource_group_name
  virtual_network_name        = var.virtual_network_name
  location                    = var.location
  ip_configuration_name       = var.ip_configuration_name
  subnet_id                   = var.subnet_id
  network_security_group_name = var.network_security_group_name

  tags = merge(local.tags, {
    DeployedBy = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}

##################################################
# RESOURCES                                      #
##################################################
resource "azurerm_windows_virtual_machine" "virtual_machine" {
  name                = var.name
  computer_name       = substr(var.name, 10, 15) # computer_name can only be 15 characters maximum
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.size
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [
    module.mod_virtual_machine_nic.network_interface_id
  ]

  boot_diagnostics {
    storage_account_uri = var.boot_diagnostics_storage_account == "" ? null : var.boot_diagnostics_storage_account
  }

  os_disk {
    name                 = "${var.name}OsDisk"
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_account_type
  }

  source_image_reference {
    offer     = lookup(var.os_disk_image, "offer", null)
    publisher = lookup(var.os_disk_image, "publisher", null)
    sku       = lookup(var.os_disk_image, "sku", null)
    version   = lookup(var.os_disk_image, "version", null)
  }

  identity {
    type = "SystemAssigned"
  }

  tags = merge(var.tags, {
    DeployedBy = format("AzureNoOpsTF [%s]", terraform.workspace)
  })

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      admin_username,
      admin_password,
      identity,
      license_type,
      os_disk, # Prevent restored OS disks from causinf terraform to attempt to re-create the original os disk name and break the restores OS
      custom_data,
      additional_capabilities,
    ]
  }
}

resource "azurerm_managed_disk" "vm_data_disk" {
  for_each             = var.data_disks
  name                 = format("%s-%s-vm-disk-%s", var.name, var.location, each.key)
  location             = var.location
  create_option        = each.value
  disk_size_gb         = each.value
  resource_group_name  = var.resource_group_name
  storage_account_type = each.value
}

resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  for_each           = var.data_disks
  virtual_machine_id = azurerm_windows_virtual_machine.virtual_machine.id
  managed_disk_id    = azurerm_managed_disk.vm_data_disk[each.key].id
  lun                = each.key
  caching            = each.value
}

resource "azurerm_virtual_machine_extension" "custom_script" {
  count                = var.script_name == "" ? 0 : 1
  name                 = "${var.name}CustomScript"
  virtual_machine_id   = azurerm_windows_virtual_machine.virtual_machine.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
      "fileUris": ["https://${var.script_storage_account_name}.blob.core.windows.net/${var.container_name}/${var.script_name}"],
      "commandToExecute": "bash ${var.script_name}"
    }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "storageAccountName": "${var.script_storage_account_name}",
      "storageAccountKey": "${var.script_storage_account_key}"
    }
  PROTECTED_SETTINGS

  lifecycle {
    ignore_changes = [
      tags,
      settings,
      protected_settings
    ]
  }
}

resource "azurerm_virtual_machine_extension" "monitor_agent" {
  count                      = var.script_name == "" ? 0 : 1
  name                       = "${var.name}MonitoringAgent"
  virtual_machine_id         = azurerm_windows_virtual_machine.virtual_machine.id
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "OmsAgentForLinux"
  type_handler_version       = "1.12"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "workspaceId": "${var.log_analytics_workspace_id}"
    }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "workspaceKey": "${var.log_analytics_workspace_key}"
    }
  PROTECTED_SETTINGS

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
  depends_on = [azurerm_virtual_machine_extension.custom_script]
}

resource "azurerm_virtual_machine_extension" "dependency_agent" {
  count                      = var.script_name == "" ? 0 : 1
  name                       = "${var.name}DependencyAgent"
  virtual_machine_id         = azurerm_windows_virtual_machine.virtual_machine.id
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentLinux"
  type_handler_version       = "9.10"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "workspaceId": "${var.log_analytics_workspace_id}"
    }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "workspaceKey": "${var.log_analytics_workspace_key}"
    }
  PROTECTED_SETTINGS

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
  depends_on = [azurerm_virtual_machine_extension.monitor_agent]
}
