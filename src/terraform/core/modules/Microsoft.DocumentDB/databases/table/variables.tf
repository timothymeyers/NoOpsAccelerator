# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.


variable "cosmosdb_account_name" {
  type        = string
  description = "The name of the Cosmos DB account."  
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Cosmos DB account."
}

variable "tables" {
  type = map(object({
    table_name           = string
    table_throughput     = number
    table_max_throughput = number
  }))
  description = "Map of Cosmos DB Tables to create. Some parameters are inherited from cosmos account."
  default     = {}
}