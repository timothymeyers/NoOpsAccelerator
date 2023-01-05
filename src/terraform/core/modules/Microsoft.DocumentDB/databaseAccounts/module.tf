# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.


data "azurerm_subnet" "subnet" {
  for_each             = { for x in var.allowed_networks : x.subnet_name => x }
  name                 = each.value.subnet_name
  virtual_network_name = each.value.vnet_name
  resource_group_name  = each.value.networking_resource_group != null ? each.value.networking_resource_group : var.resource_group_name
}

##################################################
# RESOURCES                                      #
##################################################
# -
# - Azure CosmosDB Account
# -
resource "azurerm_cosmosdb_account" "db" {
  name                = lookup(var.cosmosdb_account, "database_name")
  resource_group_name = var.resource_group_name
  location            = var.location
  offer_type          = coalesce(lookup(var.cosmosdb_account, "offer_type"), "Standard")
  kind                = coalesce(lookup(var.cosmosdb_account, "kind"), "MongoDB")

  enable_multiple_write_locations = coalesce(lookup(var.cosmosdb_account, "enable_multiple_write_locations"), false)
  enable_automatic_failover       = coalesce(lookup(var.cosmosdb_account, "enable_automatic_failover"), true)

  is_virtual_network_filter_enabled = coalesce(lookup(var.cosmosdb_account, "is_virtual_network_filter_enabled"), true)
  ip_range_filter                   = lookup(var.cosmosdb_account, "ip_range_filter")

  dynamic "virtual_network_rule" {
    for_each = coalesce(var.allowed_networks, [])
    content {
      id = lookup(data.azurerm_subnet.subnet, virtual_network_rule.value.subnet_name)["id"]
    }
  }

  dynamic "capabilities" {
    for_each = coalesce(lookup(var.cosmosdb_account, "api_type"), "MongoDBv3.4") != null ? [coalesce(lookup(var.cosmosdb_account, "api_type"), "MongoDBv3.4")] : []
    content {
      name = capabilities.value
    }
  }

  consistency_policy {
    consistency_level       = coalesce(lookup(var.cosmosdb_account, "consistency_level"), "BoundedStaleness")
    max_interval_in_seconds = coalesce(lookup(var.cosmosdb_account, "consistency_level"), "BoundedStaleness") == "BoundedStaleness" ? coalesce(lookup(var.cosmosdb_account, "max_interval_in_seconds"), 300) : null
    max_staleness_prefix    = coalesce(lookup(var.cosmosdb_account, "consistency_level"), "BoundedStaleness") == "BoundedStaleness" ? coalesce(lookup(var.cosmosdb_account, "max_staleness_prefix"), 100000) : null
  }

  geo_location {
    location          = lookup(var.cosmosdb_account, "failover_location")
    failover_priority = 1
  }

  geo_location {
    prefix            = "${lookup(var.cosmosdb_account, "database_name")}-main"
    location          = local.resourcegroup_state_exists == true ? lookup(data.terraform_remote_state.resourcegroup.outputs.resource_group_locations_map, var.resource_group_name) : data.azurerm_resource_group.this.0.location
    failover_priority = 0
  }

  tags = local.tags
}

# -
# - Create Mongo DB
# -
module "mongodb" {
  source = "./mongodbDatabases"
  depends_on          = [azurerm_cosmosdb_account.this]
  cosmosdb_account_name        = azurerm_cosmosdb_account.db.name
  resource_group_name          = var.resource_group_name
  provision_mongo_db           = local.provisionMongoDB
  provision_cassandra_keyspace = local.provisionCassandraKeyspace
  provision_cosmos_table       = local.provisionTable
  tags                         = local.tags
}

# -
# - Create Sql DB
# -