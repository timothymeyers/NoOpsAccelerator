# Copyright (c) Microsoft Corporation.
# Licensed under the MIT Lice

#---------------------------------------------------------
#  CosmosDB Table - Default is "false" 
#---------------------------------------------------------
resource "azurerm_cosmosdb_table" "main" {
  count               = var.create_cosmosdb_table ? 1 : 0
  name                = var.cosmosdb_table_name == null ? format("%s-table", element([for n in azurerm_cosmosdb_account.main : n.name], 0)) : var.cosmosdb_table_name
  resource_group_name = local.resource_group_name
  account_name        = element([for n in azurerm_cosmosdb_account.main : n.name], 0)
  throughput          = var.cosmosdb_table_autoscale_settings == null ? var.cosmosdb_table_throughput : null

  dynamic "autoscale_settings" {
    for_each = var.cosmosdb_table_autoscale_settings != null ? [var.cosmosdb_table_autoscale_settings] : []
    content {
      max_throughput = var.cosmosdb_table_throughput == null ? var.cosmosdb_table_autoscale_settings.max_throughput : null
    }
  }
}