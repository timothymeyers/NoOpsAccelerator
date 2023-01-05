# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

terraform {
  required_providers {
     azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

locals {
  provisionMongoDB           = (coalesce(lookup(var.cosmosdb_account, "api_type"), "MongoDBv3.4") == "MongoDBv3.4" || coalesce(lookup(var.cosmosdb_account, "api_type"), "MongoDBv3.4") == "EnableMongo") && coalesce(lookup(var.cosmosdb_account, "kind"), "MongoDB") == "MongoDB"
  provisionCassandraKeyspace = coalesce(lookup(var.cosmosdb_account, "api_type"), "MongoDBv3.4") == "EnableCassandra" && coalesce(lookup(var.cosmosdb_account, "kind"), "MongoDB") == "GlobalDocumentDB"
  provisionTable             = coalesce(lookup(var.cosmosdb_account, "api_type"), "MongoDBv3.4") == "EnableTable" && coalesce(lookup(var.cosmosdb_account, "kind"), "MongoDB") == "GlobalDocumentDB"
}