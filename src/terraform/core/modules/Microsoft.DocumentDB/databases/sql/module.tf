# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

##################################################
# RESOURCES                                      #
##################################################
resource "azurerm_cosmosdb_sql_database" "main" {
  count               = var.create_cosmosdb_sql_database || var.create_cosmosdb_sql_container ? 1 : 0
  name                = var.cosmosdb_sql_database_name
  resource_group_name = var.resource_group_name
  account_name        = var.cosmosdb_account_name
  throughput          = var.cosmosdb_sqldb_autoscale_settings == null ? var.cosmosdb_sqldb_throughput : null

  dynamic "autoscale_settings" {
    for_each = var.cosmosdb_table_autoscale_settings != null ? [var.cosmosdb_table_autoscale_settings] : []
    content {
      max_throughput = var.cosmosdb_sqldb_throughput == null ? var.cosmosdb_table_autoscale_settings.max_throughput : null
    }
  }
}

#---------------------------------------------------------
#  CosmosDB SQL Container API 
#---------------------------------------------------------
resource "azurerm_cosmosdb_sql_container" "main" {
  count                  = var.create_cosmosdb_sql_container ? 1 : 0
  name                   = var.cosmosdb_sql_container_name
  resource_group_name    = var.resource_group_name
  account_name           = var.cosmosdb_account_name
  database_name          = azurerm_cosmosdb_sql_database.main.0.name
  partition_key_path     = var.partition_key_path
  partition_key_version  = var.partition_key_version
  throughput             = var.sql_container_autoscale_settings == null ? var.sql_container_throughput : null
  default_ttl            = var.default_ttl
  analytical_storage_ttl = var.analytical_storage_ttl

  dynamic "unique_key" {
    for_each = var.unique_key != null ? [var.unique_key] : []
    content {
      paths = var.unique_key.paths
    }
  }

  dynamic "autoscale_settings" {
    for_each = var.sql_container_autoscale_settings != null ? [var.sql_container_autoscale_settings] : []
    content {
      max_throughput = var.sql_container_throughput == null ? var.sql_container_autoscale_settings.max_throughput : null
    }
  }

  dynamic "indexing_policy" {
    for_each = var.indexing_policy != null ? [var.indexing_policy] : []
    content {
      indexing_mode = var.indexing_policy.indexing_mode

      dynamic "included_path" {
        for_each = lookup(var.indexing_policy, "included_path") != null ? [lookup(var.indexing_policy, "included_path")] : []
        content {
          path = var.indexing_policy.included_path.path
        }
      }

      dynamic "excluded_path" {
        for_each = lookup(var.indexing_policy, "excluded_path") != null ? [lookup(var.indexing_policy, "excluded_path")] : []
        content {
          path = var.indexing_policy.excluded_path.path
        }
      }

      dynamic "composite_index" {
        for_each = lookup(var.indexing_policy, "composite_index") != null ? [lookup(var.indexing_policy, "composite_index")] : []
        content {
          index {
            path  = var.indexing_policy.composite_index.index.path
            order = var.indexing_policy.composite_index.index.order
          }
        }
      }

      dynamic "spatial_index" {
        for_each = lookup(var.indexing_policy, "spatial_index") != null ? [lookup(var.indexing_policy, "spatial_index")] : []
        content {
          path = var.indexing_policy.spatial_index.path
        }
      }
    }
  }

  dynamic "conflict_resolution_policy" {
    for_each = var.conflict_resolution_policy != null ? [var.conflict_resolution_policy] : []
    content {
      mode                          = var.conflict_resolution_policy.mode
      conflict_resolution_path      = var.conflict_resolution_policy.conflict_resolution_path
      conflict_resolution_procedure = var.conflict_resolution_policy.conflict_resolution_procedure
    }
  }
}