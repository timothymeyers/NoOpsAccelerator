# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#############################################
# DATA                                      #
#############################################
data "azurerm_cosmosdb_account" "this" { 
  name                = var.cosmosdb_account_name
  resource_group_name = var.resource_group_name  
}

##################################################
# RESOURCES                                      #
##################################################
# -
# - Create SQL DB
# -
resource "azurerm_cosmosdb_sql_database" "this" {
  count               = var.provision_mongo_db ? 1 : 0
  name                = "cosmos-sql-db"
  resource_group_name = var.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.this.name
  throughput          = var.throughput
  depends_on          = [azurerm_cosmosdb_account.this]
}

# -
# - Create SQL Collection
# -
resource "azurerm_cosmosdb_mongo_collection" "this" {
  count               = var.provision_mongo_db ? 1 : 0
  name                = "cosmos-sql-collection"
  resource_group_name = var.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.this.name
  database_name       = element(azurerm_cosmosdb_mongo_database.this.*.name, 0)

  default_ttl_seconds = var.default_ttl_seconds
  shard_key           = var.shard_key
  throughput          = var.throughput

  dynamic "index" {
    for_each = coalesce(var.indexes, [{ keys = ["_id"], unique = false }])
    content {
      keys   = index.value.keys
      unique = coalesce(index.value.unique, false)
    }
  }

  depends_on = [azurerm_cosmosdb_account.this, azurerm_cosmosdb_mongo_database.this]
}

# -
# - Creates SQL DB Cassendra Keyspace
# -
resource "azurerm_cosmosdb_cassandra_keyspace" "this" {
  count               = var.provision_cassandra_key_space ? 1 : 0
  name                = "cosmos-cassandra-keyspace"
  resource_group_name = var.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.this.name
  throughput          = var.throughput
  depends_on          = [azurerm_cosmosdb_account.this]
}

# -
# - Creates SQL DB Table
# -
resource "azurerm_cosmosdb_table" "this" {
  count               = var.provision_cosmos_table ? 1 : 0
  name                = "cosmos-table"
  resource_group_name = lvar.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.this.name
  throughput          = var.throughput
  depends_on          = [azurerm_cosmosdb_account.this]
}