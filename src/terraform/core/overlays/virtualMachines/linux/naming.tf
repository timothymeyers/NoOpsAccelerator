# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

data "azurenoopsutils_resource_name" "vm" {
  name          = var.workload_name
  resource_type = "azurerm_linux_virtual_machine"
  prefixes      = [var.org_name]
  suffixes      = compact([var.name_prefix == "" ? null : local.name_prefix, var.deploy_environment, local.name_suffix, var.use_naming ? "" : "vm"])
  use_slug      = var.use_naming
  clean_input   = true
}

data "azurenoopsutils_resource_name" "pub_ip" {
  name          = var.workload_name
  resource_type = "azurerm_public_ip"
  prefixes      = [var.org_name]
  suffixes      = compact([var.name_prefix == "" ? null : local.name_prefix, var.deploy_environment, local.name_suffix, var.use_naming ? "" : "pip"])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}

data "azurenoopsutils_resource_name" "nic" {
  name          = var.workload_name
  resource_type = "azurerm_network_interface"
  prefixes      = [var.org_name]
  suffixes      = compact([var.name_prefix == "" ? null : local.name_prefix, var.deploy_environment, local.name_suffix, var.use_naming ? "" : "nic"])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}

data "azurenoopsutils_resource_name" "avail_set" {
  name          = var.workload_name
  resource_type = "azurerm_availability_set"
  prefixes      = [var.org_name]
  suffixes      = compact([var.name_prefix == "" ? null : local.name_prefix, var.deploy_environment, local.name_suffix, var.use_naming ? "" : "nic"])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}

data "azurenoopsutils_resource_name" "disk" {
  for_each = var.data_disks

  name          = var.workload_name
  resource_type = "azurerm_managed_disk"
  prefixes      = [var.org_name]
  suffixes      = compact([var.name_prefix == "" ? null : local.name_prefix, var.deploy_environment, local.name_suffix, var.use_naming ? "" : "disk"])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}
