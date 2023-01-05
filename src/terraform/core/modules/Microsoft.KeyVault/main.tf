# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }

}

locals {
  default_network_acls = {
    bypass                     = "AzureServices"
    default_action             = "Deny"
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }
  disable_network_acls = {
    bypass                     = "None"
    default_action             = "Allow"
    ip_rules                   = null
    virtual_network_subnet_ids = null
  }

  merged_network_acls = var.network_acls != null ? merge(local.default_network_acls, var.network_acls) : null

  module_tag = {
    "module" = basename(abspath(path.module))
  }
  tags = merge(var.tags, local.module_tag)
}
