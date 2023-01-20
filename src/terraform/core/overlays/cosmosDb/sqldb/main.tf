# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module to deploy a Cosmos DB Account with a SQL API Database
DESCRIPTION: The following components will be options in this deployment
                Cosmos DB Account
                SQL API Database
AUTHOR/S: jspinella
*/

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

# Private DNS Zone for SQL API 


# Cosmos DB Account
module "azure_cosmos_db" {
  source = "../../modules/Microsoft.DocumentDB/databaseAccounts"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  cosmos_account_name = var.cosmos_account_name
  cosmos_api          = var.cosmos_api
}

module "azure_cosmos_sql_db" {
  source = "../../modules/Microsoft.DocumentDB/databaseAccounts/sqlDatabases"

  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location
  cosmos_account_name = module.azure_cosmos_db.cosmos_account_name
  sql_dbs             = var.sql_dbs
  sql_db_containers   = var.sql_db_containers
  depends_on = [
    module.azure_cosmos_db
  ]
}
