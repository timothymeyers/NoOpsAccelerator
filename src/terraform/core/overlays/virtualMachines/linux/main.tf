# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#----------------------------------------------------------
# Random Resources
#----------------------------------------------------------
resource "random_password" "password" {
  count       = (var.disable_password_authentication == false && var.admin_password == null ? 1 : (var.admin_password == null ? 1 : 0))
  length      = var.random_password_length
  min_upper   = 4
  min_lower   = 2
  min_numeric = 4
  special     = false

  keepers = {
    admin_password = local.vm_name
  }
}

#---------------------------------------------------------------
# Generates SSH2 key Pair for Linux VM's (Dev Environment only)
#---------------------------------------------------------------
resource "tls_private_key" "rsa" {
  count     = var.generate_admin_ssh_key ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

#---------------------------------------
# Linux Virutal machine
#---------------------------------------
resource "azurerm_linux_virtual_machine" "linux_vm" {
  count                           = var.instances_count >= 1 ? var.instances_count : 0
  name                            = var.instances_count == 1 ? substr(local.vm_name, 0, 64) : substr(format("%s%s", lower(replace(local.vm_name, "/[[:^alnum:]]/", "")), count.index + 1), 0, 64)
  computer_name                   = local.vm_hostname
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = var.virtual_machine_size
  admin_username                  = var.admin_username
  admin_password                  = (var.disable_password_authentication == false && var.admin_password == null ? random_password.password[0].result : var.admin_password)
  disable_password_authentication = var.admin_password != null ? false : true
  network_interface_ids           = [element(concat(azurerm_network_interface.nic.*.id, [""]), count.index)]
  source_image_id                 = var.source_image_id != null ? var.source_image_id : null
  provision_vm_agent              = true
  allow_extension_operations      = true
  dedicated_host_id               = var.dedicated_host_id
  custom_data                     = var.custom_data != null ? var.custom_data : null
  availability_set_id             = var.enable_vm_availability_set == true ? element(concat(azurerm_availability_set.aset.*.id, [""]), 0) : null
  encryption_at_host_enabled      = var.enable_encryption_at_host
  proximity_placement_group_id    = var.enable_proximity_placement_group ? azurerm_proximity_placement_group.appgrp.0.id : null
  zone                            = var.vm_availability_zone
  tags                            = merge({ "ResourceName" = var.instances_count == 1 ? local.vm_name : format("%s%s", lower(replace(local.vm_name, "/[[:^alnum:]]/", "")), count.index + 1) }, var.tags, )

  dynamic "admin_ssh_key" {
    for_each = var.disable_password_authentication ? [1] : []
    content {
      public_key = var.admin_ssh_key == null ? tls_private_key.rsa[0].public_key_openssh : file(var.admin_ssh_key)
      username   = var.admin_username
    }
  }

  dynamic "source_image_reference" {
    for_each = var.source_image_id != null ? [] : [1]
    content {
      publisher = var.custom_image != null ? var.custom_image["publisher"] : var.linux_distribution_list[lower(var.linux_distribution_name)]["publisher"]
      offer     = var.custom_image != null ? var.custom_image["offer"] : var.linux_distribution_list[lower(var.linux_distribution_name)]["offer"]
      sku       = var.custom_image != null ? var.custom_image["sku"] : var.linux_distribution_list[lower(var.linux_distribution_name)]["sku"]
      version   = var.custom_image != null ? var.custom_image["version"] : var.linux_distribution_list[lower(var.linux_distribution_name)]["version"]
    }
  }

  os_disk {
    storage_account_type      = var.os_disk_storage_account_type
    caching                   = var.os_disk_caching
    disk_encryption_set_id    = var.disk_encryption_set_id
    disk_size_gb              = var.disk_size_gb
    write_accelerator_enabled = var.enable_os_disk_write_accelerator
    name                      = var.os_disk_name
  }

  additional_capabilities {
    ultra_ssd_enabled = var.enable_ultra_ssd_data_disk_storage_support
  }

  dynamic "identity" {
    for_each = var.identity != null ? ["fake"] : []
    content {
      type         = var.identity.type
      identity_ids = var.identity.identity_ids
    }
  }

  dynamic "boot_diagnostics" {
    for_each = var.enable_boot_diagnostics ? [1] : []
    content {
      storage_account_uri = var.storage_account_name != null ? data.azurerm_storage_account.storeacc.0.primary_blob_endpoint : var.storage_account_uri
    }
  }

  patch_mode            = var.patch_mode
  patch_assessment_mode = var.patch_mode == "AutomaticByPlatform" ? var.patch_mode : "ImageDefault"

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

