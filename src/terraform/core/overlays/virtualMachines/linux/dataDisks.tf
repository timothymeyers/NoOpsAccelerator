# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#---------------------------------------
# Virtual machine data disks
#---------------------------------------
resource "azurerm_managed_disk" "data_disk" {
  for_each             = var.data_disks
  name                 = coalesce(each.value.name, var.use_naming ? data.azurenoopsutils_resource_name.disk[each.key].result : format("%s-datadisk%s", local.vm_name, each.key))
  resource_group_name  = var.resource_group_name
  location             = var.location
  storage_account_type = each.value.storage_account_type
  create_option        = each.value.create_option
  disk_size_gb         = each.value.disk_size_gb
  source_resource_id   = contains(["Copy", "Restore"], each.value.create_option) ? each.value.source_resource_id : null
  tags                 = merge({ "ResourceName" = "${local.vm_name}_DataDisk_${each.value.lun}" }, var.tags, )

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_disk" {
  for_each           = var.data_disks
  managed_disk_id    = azurerm_managed_disk.data_disk[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.linux_vm[0].id
  lun                = coalesce(each.value.lun, index(keys(var.data_disks), each.key))
  caching            = each.value.caching
}
