# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

##################################################
# RESOURCES                                      #
##################################################
resource "azurerm_cosmosdb_table" "main" {
  for_each = var.tables
  name                = each.value.table_name
  resource_group_name = local.resource_group_name
  account_name        = var.cosmosdb_account_name
  throughput          = each.value.table_throughput == null ? each.value.table_throughput : null

  dynamic "autoscale_settings" {
    for_each = var.cosmosdb_table_autoscale_settings != null ? [var.cosmosdb_table_autoscale_settings] : []
    content {
      max_throughput = var.cosmosdb_table_throughput == null ? var.cosmosdb_table_autoscale_settings.max_throughput : null
    }
  }
}