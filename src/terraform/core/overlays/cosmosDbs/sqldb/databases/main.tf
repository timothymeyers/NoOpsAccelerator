# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#---------------------------------------------------------
#  CosmosDB SQL Database API - Default is "false" 
#---------------------------------------------------------
resource "azurerm_cosmosdb_sql_database" "main" {
  count               = var.create_cosmosdb_sql_database || var.create_cosmosdb_sql_container ? 1 : 0
  name                = var.cosmosdb_sql_database_name == null ? format("%s-sql-database", element([for n in azurerm_cosmosdb_account.main : n.name], 0)) : var.cosmosdb_sql_database_name
  resource_group_name = local.resource_group_name
  account_name        = element([for n in azurerm_cosmosdb_account.main : n.name], 0)
  throughput          = var.cosmosdb_sqldb_autoscale_settings == null ? var.cosmosdb_sqldb_throughput : null

  dynamic "autoscale_settings" {
    for_each = var.cosmosdb_table_autoscale_settings != null ? [var.cosmosdb_table_autoscale_settings] : []
    content {
      max_throughput = var.cosmosdb_sqldb_throughput == null ? var.cosmosdb_table_autoscale_settings.max_throughput : null
    }
  }
}