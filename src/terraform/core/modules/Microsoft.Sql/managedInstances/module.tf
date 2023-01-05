# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Create a SQL Server
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server

resource "azurerm_mssql_database" "main" {
  name                                = var.sql_db_name
  server_id                           = var.sql_server_id
  collation                           = "SQL_Latin1_General_CP1_CI_AS"
  license_type                        = "LicenseIncluded"
  max_size_gb                         = var.db_max_size_gb
  sku_name                            = var.sku_name
  zone_redundant                      = var.zone_redundant
  read_scale                          = var.read_scale     # conditional so only set if SKU is Premium and Business Critical
  storage_account_type                = var.storage_account_type
  transparent_data_encryption_enabled = true
  tags                                = var.tags
}
