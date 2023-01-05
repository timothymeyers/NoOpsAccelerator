# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# This module deploys an Availability Set
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/availability_set

##################################################
# RESOURCES                                      #
##################################################
resource "azurerm_availability_set" "avset" {
  name                         = var.name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  tags                         = var.tags
  platform_update_domain_count = var.platform_update_domain_count
  platform_fault_domain_count  = var.platform_fault_domain_count
  managed                      = try(var.managed, true)
  proximity_placement_group_id = var.ppg_id
}

