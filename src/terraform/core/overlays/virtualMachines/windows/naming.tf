# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

data "azurecaf_name" "vm" {
  name          = var.workload_name
  resource_type = "azurerm_windows_virtual_machine"
  prefixes      = var.name_prefix == "" ? null : [local.name_prefix]
  suffixes      = compact([var.org_name, var.location_short, var.environment, local.name_suffix, var.use_caf_naming ? "" : "vm"])
  use_slug      = var.use_caf_naming
  clean_input   = true
  separator     = "-"
}

data "azurecaf_name" "pub_ip" {
  name          = var.workload_name
  resource_type = "azurerm_public_ip"
  prefixes      = var.name_prefix == "" ? null : [local.name_prefix]
  suffixes      = compact([var.org_name, var.location_short, var.environment, local.name_suffix, var.use_caf_naming ? "" : "pubip"])
  use_slug      = var.use_caf_naming
  clean_input   = true
  separator     = "-"
}

data "azurecaf_name" "nic" {
  name          = var.workload_name
  resource_type = "azurerm_network_interface"
  prefixes      = var.name_prefix == "" ? null : [local.name_prefix]
  suffixes      = compact([var.org_name, var.location_short, var.environment, local.name_suffix, var.use_caf_naming ? "" : "nic"])
  use_slug      = var.use_caf_naming
  clean_input   = true
  separator     = "-"
}

data "azurecaf_name" "disk" {
  for_each = var.data_disks

  name          = var.workload_name
  resource_type = "azurerm_managed_disk"
  prefixes      = var.name_prefix == "" ? null : [local.name_prefix]
  suffixes      = compact([var.org_name, var.location_short, var.environment, each.key])
  use_slug      = var.use_caf_naming
  clean_input   = true
  separator     = "-"
}