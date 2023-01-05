# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "provision_mongo_db" {
  type        = bool
  description = "If true, will provision a MongoDB database"
  default     = false
} 

variable "provision_cosmos_table" {
  type        = bool
  description = "If true, will provision a Cosmos Table"
  default     = false
}

variable "provision_cassandra_keyspace" {
  type        = bool
  description = "If true, will provision a Cassandra Keyspace"
  default     = false
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Azure CosmosDB"
}

variable "cosmosdb_account_name" {
  type        = string
  description = "The name of the Cosmos DB account."
}

variable "throughput" {
  type        = number
  description = "The throughput of Mongo Collection/Cassandra Keyspace/Table (RU/s). Must be set in increments of 100. The minimum value is 400. This must be set upon database creation otherwise it cannot be updated without a manual terraform destroy-apply."
  default     = 400
}

variable "default_ttl_seconds" {
  type        = string
  description = "The default Time To Live in seconds. If the value is -1 or 0, items are not automatically expired."
  default     = "777"
}

variable "shard_key" {
  type        = string
  description = "The name of the key to partition on for sharding. There must not be any other unique index keys."
  default     = "uniqueKey"
}

variable "indexes" {
  type = list(object({
    keys   = list(string)
    unique = bool
  }))
  description = "Specifies the list of Cosmos MongoDB Collection indexes"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "If specified, will set the default tags for all resources deployed by this module where supported."
  default     = {}
}