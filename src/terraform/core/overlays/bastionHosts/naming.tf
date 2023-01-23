# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

data "azurecaf_name" "bastion" {
  name          = var.stack
  resource_type = "azurerm_bastion_host"
  prefixes      = var.name_prefix == "" ? null : [local.name_prefix]
  suffixes      = compact([var.org_name, var.location_short, var.deploy_environment, local.name_suffix, var.use_caf_naming ? "" : local.anoa_slug])
  use_slug      = var.use_caf_naming
  clean_input   = true
  separator     = "-"
}

data "azurecaf_name" "bastion_pip" {
  name          = var.stack
  resource_type = "azurerm_public_ip"
  prefixes      = var.name_prefix == "" ? null : [local.name_prefix]
  suffixes      = compact([var.org_name, var.location_short, var.deploy_environment, var.location_short, local.name_suffix, var.use_caf_naming ? "" : "pubip"])
  use_slug      = var.use_caf_naming
  clean_input   = true
  separator     = "-"
}