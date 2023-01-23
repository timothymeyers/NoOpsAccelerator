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

#-------------------------------------------------------------
#  CosmosDB azure defender configuration - Default is "false" 
#-------------------------------------------------------------
resource "azurerm_advanced_threat_protection" "example" {
  count              = var.enable_advanced_threat_protection ? 1 : 0
  target_resource_id = element([for n in azurerm_cosmosdb_account.main : n.id], 0)
  enabled            = var.enable_advanced_threat_protection
}

#------------------------------------------------------------
# Cosmos Db Sql Instance configuration - Default (required). 
#------------------------------------------------------------
resource "azurerm_cosmosdb_account" "db" {
  name = local.cosmosdb_name

  location            = var.location
  resource_group_name = var.resource_group_name

  offer_type           = var.offer_type
  kind                 = var.kind
  mongo_server_version = var.kind == "MongoDB" ? var.mongo_server_version : null

  enable_automatic_failover = true

  analytical_storage_enabled = var.analytical_storage_enabled

  dynamic "analytical_storage" {
    for_each = var.analytical_storage_type != null ? ["enabled"] : []
    content {
      schema_type = var.analytical_storage_type
    }
  }

  dynamic "geo_location" {
    for_each = var.failover_locations != null ? var.failover_locations : local.default_failover_locations
    content {
      location          = geo_location.value.location
      failover_priority = lookup(geo_location.value, "priority", 0)
      zone_redundant    = lookup(geo_location.value, "zone_redundant", false)
    }
  }

  consistency_policy {
    consistency_level       = var.consistency_policy_level
    max_interval_in_seconds = var.consistency_policy_max_interval_in_seconds
    max_staleness_prefix    = var.consistency_policy_max_staleness_prefix
  }

  dynamic "capabilities" {
    for_each = toset(var.capabilities)
    content {
      name = capabilities.key
    }
  }

  ip_range_filter = join(",", var.allowed_cidrs)

  public_network_access_enabled         = var.public_network_access_enabled
  is_virtual_network_filter_enabled     = var.is_virtual_network_filter_enabled
  network_acl_bypass_for_azure_services = var.network_acl_bypass_for_azure_services
  network_acl_bypass_ids                = var.network_acl_bypass_ids

  dynamic "virtual_network_rule" {
    for_each = var.virtual_network_rule != null ? toset(var.virtual_network_rule) : []
    content {
      id                                   = virtual_network_rule.value.id
      ignore_missing_vnet_service_endpoint = virtual_network_rule.value.ignore_missing_vnet_service_endpoint
    }
  }

  dynamic "backup" {
    for_each = var.backup != null ? ["enabled"] : []
    content {
      type                = lookup(var.backup, "type", null)
      interval_in_minutes = lookup(var.backup, "interval_in_minutes", null)
      retention_in_hours  = lookup(var.backup, "retention_in_hours", null)
    }
  }

  dynamic "identity" {
    for_each = var.identity_type != null ? ["enabled"] : []
    content {
      type = var.identity_type
    }
  }

  tags = merge(local.default_tags, var.extra_tags)
}