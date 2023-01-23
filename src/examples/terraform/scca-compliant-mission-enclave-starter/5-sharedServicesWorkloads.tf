# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module Example to deploy Shared Services (Tier 2) Workloads for the SCCA Compliant Mission Enclave
DESCRIPTION: The following components will be options in this deployment
            * Azure Cosmos DB
            * Azure Redis Cache
            * Azure Key Vault 
            * Azure Event Hub for Logging and Policy
AUTHOR/S: jspinella
*/

#########################################################
### STAGE 5: Shared Services Workloads Configuations  ###
#########################################################

# Create Subnet for Private Endpoints
module "mod_svcs_private_ep_snet" {
  depends_on = [
    module.mod_svcs_network
  ]
  source                                        = "../../../terraform/core/modules/Microsoft.Network/subnets"
  subnet_name                                   = local.svcsPrivateEndpointSubnetName
  resource_group_name                           = module.mod_svcs_network.resource_group_name
  location                                      = module.mod_azure_region.location
  virtual_network_name                          = module.mod_svcs_network.virtual_network_name
  address_prefixes                              = ["10.0.120.32/28"] # This is a /28 subnet, which allows for 14 private endpoints
  service_endpoints                             = []
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = false
}


# Build the Shared Cosmos DB
/* module "mod_svcs_cosmosdb" {
  depends_on = [
    module.mod_svcs_network,
    module.mod_svcs_private_ep_snet # Wait for the network to be built
  ]
  source = "../../../terraform/core/overlays/cosmosDbs/sqldb"

  # By default, this module will not create a resource group
  # provide a name to use an existing resource group, specify the existing resource group name,
  # and set the argument to `create_resource_group = false`. Location will be same as existing RG.
  create_cosmos_sqldb_resource_group = var.create_cosmos_sqldb_resource_group

  # The name of the resource group in which to create the CosmosDB account.
  resource_group_name         = module.mod_svcs_network.resource_group_name
  location                    = var.location
  location_short              = "usgovva"
  environment                 = var.environment
  org_name                    = var.org_name
  workload_name               = var.workload_name

  # Cosmosdb account details.
  # Currently Offer Type supports only be set to `Standard`
  # Specifies the Kind of CosmosDB to create - possible values are `GlobalDocumentDB` and `MongoDB`
  cosmosdb_account_config = var.cosmosdb_account_config

  # Advanced Threat Protection for Azure Cosmos DB represents an additional layer of protection
  enable_advanced_threat_protection = var.enable_advanced_threat_protection

  # `max_staleness_prefix` must be greater then `100000` when more then one geo_location is used
  # `max_interval_in_seconds` must be greater then 300 (5min) when more then one geo_location is used
  consistency_policy = {
    consistency_level       = "BoundedStaleness"
    max_staleness_prefix    = 100000
    max_interval_in_seconds = 300
  }

  # SQL databases under an Azure Cosmos DB account
  # To use a custom name, set an argument `cosmosdb_sql_database_name` to valid string
  # Either `cosmosdb_sqldb_throughput` or `cosmosdb_sqldb_autoscale_settings` to be present and not both
  # Switching between autoscale and manual throughput is not supported via Terraform and manual task.
  # The minimum value for `throughput` is `400` and `autoscale_settings` minimum value is `10000`
  create_cosmosdb_sql_database = var.create_cosmosdb_sql_database
  cosmosdb_sql_database_name   = local.svcsCosmosDbName

  # Create an SQL container under an Azure Cosmos DB SQL database
  # The default indexing policy for newly created containers indexes every property of every item
  # Recommended to use an opt-out `indexing policy` to let Azure Cosmos DB proactively index
  # You can define unique keys only when you create an Azure Cosmos container
  create_cosmosdb_sql_container = var.create_cosmosdb_sql_container
  cosmosdb_sql_container_name   = local.svcsCosmosDbContainerName
  sql_container_throughput      = 400

  # Creating Private Endpoint requires, VNet name to create a Private Endpoint
  # By default this will create a `privatelink.documents.azure.com` DNS zone. if created in commercial cloud
  # To use existing subnet, specify `existing_subnet_id` with valid subnet id. 
  # To use existing private DNS zone specify `existing_private_dns_zone` with valid zone name
  # Private endpoints doesn't work If using `subnet_id` to create redis inside a specified VNet.
  enable_private_endpoint = true
  existing_subnet_id      = module.mod_svcs_private_ep_snet.id
  virtual_network_name    = module.mod_svcs_network.virtual_network_name
  #  existing_private_dns_zone     = "demo.example.com"
}
 */

module "mod_svcs_redis" {
  depends_on = [
    module.mod_svcs_network,
    module.mod_svcs_private_ep_snet # Wait for the network to be built
  ]
  source = "../../../terraform/core/overlays/redisCaches"

  # By default, this module will create a resource group and 
  # provide a name for an existing resource group. If you wish 
  # to use an existing resource group, change the option 
  # to "create resource group = false." The location of the group 
  # will remain the same if you use the current resource.
  create_redis_resource_group = false
  resource_group_name         = module.mod_svcs_network.resource_group_name
  location                    = module.mod_azure_region.location
  location_short              = module.mod_azure_region.location_short
  environment                 = var.environment
  org_name                    = var.required.org_prefix
  workload_name               = local.svcsShortName


  # Configuration to provision a Standard Redis Cache
  # Specify `shared_count` to create on the Redis Cluster
  cluster_shard_count = 3

  # MEMORY MANAGEMENT
  # Azure Cache for Redis instances are configured with the following default Redis configuration values:
  redis_configuration = {
    maxmemory_reserved = 2
    maxmemory_delta    = 2
    maxmemory_policy   = "allkeys-lru"
  }

  # Nodes are patched one at a time to prevent data loss. Basic caches will have data loss.
  # Clustered caches are patched one shard at a time. 
  # The Patch Window lasts for 5 hours from the `start_hour_utc`
  patch_schedules = [
    {
      day_of_week    = "Saturday"
      start_hour_utc = 10
    }
  ]

  # Creating Private Endpoint requires, VNet name to create a Private Endpoint
  # By default this will create a `privatelink.redis.cache.windows.net` DNS zone. if created in commercial cloud
  # To use existing subnet, specify `existing_subnet_id` with valid subnet id. 
  # To use existing private DNS zone specify `existing_private_dns_zone` with valid zone name
  # Private endpoints doesn't work If using `subnet_id` to create redis inside a specified VNet.
  enable_private_endpoint = true
  existing_subnet_id      = module.mod_svcs_private_ep_snet.id
  virtual_network_name    = module.mod_svcs_network.virtual_network_name
  #  existing_private_dns_zone     = "demo.example.com"

  # Tags for Azure Resources
  extra_tags = var.tags
}

# Build the Shared Event Hub for Policy
/* module "mod_svcs_eventHub" {
  depends_on = [
    module.mod_svcs_network,
    module.mod_svcs_private_ep_snet # Wait for the network to be built
  ]
  source = "../../../terraform/core/overlays/eventHubs"

  # By default, this module will create a resource group and 
  # provide a name for an existing resource group. If you wish 
  # to use an existing resource group, change the option 
  # to "create resource group = false." The location of the group 
  # will remain the same if you use the current resource.
  create_redis_resource_group = false
  resource_group_name         = module.mod_svcs_network.resource_group_name
  location                    = module.mod_azure_region.location
  location_short              = "usgovva"
  environment                 = var.environment
  org_name                    = var.required.org_prefix
  workload_name               = local.svcsShortName

  create_dedicated_cluster = true

  namespace_parameters = {
    sku      = "Standard"
    capacity = 2
  }

  namespace_authorizations = {
    listen = true
    send   = false
  }
} */

# Build the Shared Key Vault
//module "mod_svcs_kv" {}

