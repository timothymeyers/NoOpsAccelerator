# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

data "azurenoopsutils_resource_name" "redis" {
  name          = var.workload_name
  resource_type = "azurerm_redis_cache"
  prefixes      = var.name_prefix == "" ? null : [local.name_prefix]
  suffixes      = compact([var.org_name, var.location_short, var.environment, local.name_suffix, var.use_naming ? "" : "redis"])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}

data "azurenoopsutils_resource_name" "data_storage" {
  name          = var.workload_name
  resource_type = "azurerm_storage_account"
  prefixes      = compact([local.name_prefix, "redis"])
  suffixes      = compact([var.org_name, var.location_short, var.environment, local.name_suffix, var.use_naming ? "" : "st"])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}

data "azurenoopsutils_resource_name" "redis_fw_rule" {
  for_each = var.authorized_cidrs

  name          = var.workload_name
  resource_type = "azurerm_redis_firewall_rule"
  prefixes      = var.name_prefix == "" ? null : [local.name_prefix]
  suffixes      = compact([var.org_name, var.location_short, var.environment, local.name_suffix, each.key])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}
