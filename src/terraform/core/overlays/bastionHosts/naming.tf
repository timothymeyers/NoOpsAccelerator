# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

data "azurenoopsutils_resource_name" "bastion" {
  name          = "bastion"
  resource_type = "azurerm_bastion_host"
  prefixes      = var.name_prefix == "" ? null : [local.name_prefix]
  suffixes      = compact([var.org_prefix, var.deploy_environment, local.name_suffix, var.use_naming ? "" : local.anoa_slug])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}

data "azurenoopsutils_resource_name" "bastion_pip" {
  name          = "bastion"
  resource_type = "azurerm_public_ip"
  prefixes      = var.name_prefix == "" ? null : [local.name_prefix]
  suffixes      = compact([var.org_prefix, var.deploy_environment, local.name_suffix, var.use_naming ? "" : "pubip"])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}
