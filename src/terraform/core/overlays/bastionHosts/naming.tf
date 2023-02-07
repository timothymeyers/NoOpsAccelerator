# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

data "azurenoopsutils_resource_name" "bastion" {
  name          = var.workload_name
  resource_type = "azurerm_bastion_host"
  prefixes      = [var.org_name]  
  suffixes      = compact([var.name_prefix == "" ? null : local.name_prefix, var.deploy_environment, local.name_suffix, var.use_naming ? "" : "bas"])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}

data "azurenoopsutils_resource_name" "bastion_pip" {
  name          = var.workload_name
  resource_type = "azurerm_public_ip"
  prefixes      = [var.org_name, "bastion"]  
  suffixes      = compact([var.name_prefix == "" ? null : local.name_prefix, var.deploy_environment, local.name_suffix, var.use_naming ? "" : "pubip"])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}
