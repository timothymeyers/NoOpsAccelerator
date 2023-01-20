# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# By default, this module will not create a resource group
# provide a name to use an existing resource group, specify the existing resource group name,
# and set the argument to `create_storage_account_resource_group = false`. Location will be same as existing RG.
resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = merge({ "Name" = format("%s", var.resource_group_name) }, var.tags, )
}

data "azurerm_log_analytics_workspace" "logws" {
  count               = var.log_analytics_workspace_name != null ? 1 : 0
  name                = var.log_analytics_workspace_name
  resource_group_name = local.resource_group_name
}

#---------------------------------------------------------------
# Storage Account to keep logs and backups - Default is "false"
#----------------------------------------------------------------

resource "random_string" "str" {
  count   = var.enable_data_persistence ? 1 : 0
  length  = 6
  special = false
  upper   = false
  keepers = {
    name = var.storage_account_name
  }
}


#------------------------------------------------------------
# Redis Cache Instance configuration - Default (required). 
#------------------------------------------------------------


#----------------------------------------------------------------------
# Adding Firewall rules for Redis Cache Instance - Default is "false"
#----------------------------------------------------------------------
resource "azurerm_redis_firewall_rule" "name" {
  for_each            = var.firewall_rules != null ? { for k, v in var.firewall_rules : k => v if v != null } : {}
  name                = format("%s", each.key)
  redis_cache_name    = element([for n in azurerm_redis_cache.main : n.name], 0)
  resource_group_name = local.resource_group_name
  start_ip            = each.value["start_ip"]
  end_ip              = each.value["end_ip"]
}

#---------------------------------------------------------
# Private Link for Redis Server - Default is "false" 
#---------------------------------------------------------
data "azurerm_virtual_network" "vnet01" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = var.virtual_network_name
  resource_group_name = local.resource_group_name
}

#------------------------------------------------------------------
# azurerm monitoring diagnostics  - Default is "false" 
#------------------------------------------------------------------