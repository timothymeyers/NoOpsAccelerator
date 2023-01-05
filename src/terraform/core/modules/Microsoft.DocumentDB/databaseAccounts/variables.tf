# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Azure CosmosDB"
}

variable "location" {
  type        = string
  description = "The Azure Region in which to create the Azure CosmosDB"
}

# -
# - Azure CosmosDB Account
# -
variable "cosmosdb_account" {
  type = object({
    database_name                     = string # (Required) Specifies the name of the CosmosDB Account. 
    offer_type                        = string # (Required) Specifies the Offer Type to use for this CosmosDB Account - currently this can only be set to Standard.
    kind                              = string # (Optional) Specifies the Kind of CosmosDB to create - possible values are GlobalDocumentDB and MongoDB. Defaults to GlobalDocumentDB. 
    enable_multiple_write_locations   = bool   # (Optional) Enable multi-master support for this Cosmos DB account.
    enable_automatic_failover         = bool   # (Optional) Enable automatic fail over for this Cosmos DB account.
    is_virtual_network_filter_enabled = bool   # (Optional) Enables virtual network filtering for this Cosmos DB account.
    ip_range_filter                   = string # (Optional) This value specifies the set of IP addresses or IP address ranges in CIDR form to be included as the allowed list of client IP's for a given database account. IP addresses/ranges must be comma separated and must not contain any spaces.
    api_type                          = string # (Optional) The capabilities which should be enabled for this Cosmos DB account. Possible values are EnableAggregationPipeline, EnableCassandra, EnableGremlin, EnableTable, MongoDBv3.4, and mongoEnableDocLevelTTL.
    consistency_level                 = string # (Required) The Consistency Level to use for this CosmosDB Account - can be either BoundedStaleness, Eventual, Session, Strong or ConsistentPrefix.
    max_interval_in_seconds           = number # (Optional) When used with the Bounded Staleness consistency level, this value represents the time amount of staleness (in seconds) tolerated. Accepted range for this value is 5 - 86400 (1 day). Defaults to 5. Required when consistency_level is set to BoundedStaleness.
    max_staleness_prefix              = number # (Optional) When used with the Bounded Staleness consistency level, this value represents the number of stale requests tolerated. Accepted range for this value is 10 – 2147483647. Defaults to 100. Required when consistency_level is set to BoundedStaleness.
    failover_location                 = string # (Required) The name of the Azure region to host replicated data.
  })
  description = "Map that holds the Azure CcosmosDB Account configuration"
  default     = null
}

variable "allowed_networks" {
  type = list(object({
    subnet_name               = string
    vnet_name                 = string
    networking_resource_group = string
  }))
  description = "The List of networks that the CosmosDB Account will be connected to."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "If specified, will set the default tags for all resources deployed by this module where supported."
  default     = {}
}