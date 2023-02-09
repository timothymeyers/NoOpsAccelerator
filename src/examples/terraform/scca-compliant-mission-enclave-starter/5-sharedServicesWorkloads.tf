# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module Example to deploy Shared Services (Tier 2) Workloads for the SCCA Compliant Mission Enclave
DESCRIPTION: The following components will be options in this deployment
            * Azure Cosmos DB
            * Azure Redis Cache
            * Azure Key Vault 
            * GitHub Enterprise Server
AUTHOR/S: jspinella
*/

#########################################################
### STAGE 5: Shared Services Workloads Configuations  ###
#########################################################

#########################################
### STAGE 5.1: Build out PE Subnet    ###
#########################################

# Create Subnet for Private Endpoints
module "mod_svcs_private_ep_snet" {
  depends_on = [
    module.mod_svcs_network
  ]
  source                                        = "../../../terraform/core/modules/Microsoft.Network/subnets"
  subnet_name                                   = local.svcsPrivateEndpointSubnetName
  resource_group_name                           = module.mod_svcs_network.resource_group_name
  virtual_network_name                          = module.mod_svcs_network.virtual_network_name
  address_prefixes                              = ["10.0.120.32/28"] # This is a /28 subnet, which allows for 14 private endpoints
  service_endpoints                             = []
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = false
}


#########################################
### STAGE 5.2: Build out CosmosDB     ###
#########################################

# Build the Shared Cosmos DB
/* module "mod_svcs_cosmosdb" {
  depends_on = [
    module.mod_svcs_network,
    module.mod_svcs_private_ep_snet # Wait for the network to be built
  ]
  source = "../../../terraform/core/overlays/cosmosDbs/sqldb"

  # The name of the resource group in which to create the CosmosDB account.
  resource_group_name         = module.mod_svcs_network.resource_group_name
  location                    = module.mod_azure_region_lookup.location_cli
  location_short              = module.mod_azure_region_lookup.location_short
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
} */

#########################################
### STAGE 5.3: Build out Resis Cache  ###
#########################################

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
  location                    = module.mod_azure_region_lookup.location_cli
  environment                 = var.environment
  deploy_environment          = var.required.deploy_environment
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


###########################################
### STAGE 5.4: Build out Key Vault      ###
###########################################

# Build the Shared Key Vault
/* module "mod_svcs_kv" {
  depends_on = [
    module.mod_svcs_network,
    module.mod_svcs_private_ep_snet # Wait for the network to be built
  ]
  source = "../../../terraform/core/overlays/keyVaults"

   # Resource Group, location, VNet and Subnet details
  resource_group_name  = module.mod_svcs_network.resource_group_name
  location             = module.mod_azure_region_lookup.location_cli
  location_short       = module.mod_azure_region_lookup.location_short
  environment          = var.environment
  org_name             = var.required.org_prefix
  workload_name        = "shared"
 
  # Creating Private Endpoint requires, VNet name to create a Private Endpoint
  # By default this will create a `privatelink.redis.cache.windows.net` DNS zone. if created in commercial cloud
  # To use existing subnet, specify `existing_subnet_id` with valid subnet id. 
  # To use existing private DNS zone specify `existing_private_dns_zone` with valid zone name
  # Private endpoints doesn't work If using `subnet_id` to create redis inside a specified VNet.
  enable_private_endpoint = true
  existing_subnet_id      = module.mod_svcs_private_ep_snet.id
  //virtual_network_name    = module.mod_svcs_network.virtual_network_name
  #  existing_private_dns_zone     = "demo.example.com"

  # Tags for Azure Resources
  extra_tags = var.tags
} */

###########################################
### STAGE 5.5: Build out Github Server  ###
###########################################

# Build the Shared Github Server
module "mod_svcs_github_server" {

  depends_on = [
    module.mod_svcs_network,
    module.mod_svcs_private_ep_snet # Wait for the network to be built
  ]
  source = "../../../terraform/core/overlays/virtualMachines/linux"

  # Resource Group, location, VNet and Subnet details
  resource_group_name  = module.mod_svcs_network.resource_group_name
  location             = module.mod_azure_region_lookup.location_cli
  deploy_environment   = var.required.deploy_environment
  org_name             = var.required.org_prefix
  workload_name        = "github"
  virtual_network_name = module.mod_svcs_network.virtual_network_name
  vm_subnet_name       = module.mod_svcs_network.default_subnet_name
  virtual_machine_name = "linux"

  # This module support multiple Pre-Defined Linux and Windows Distributions.
  # Check the README.md file for more pre-defined images for Ubuntu, Centos, RedHat.
  # Please make sure to use gen2 images supported VM sizes if you use gen2 distributions
  # Specify `disable_password_authentication = false` to create random admin password
  # Specify a valid password with `admin_password` argument to use your own password 
  # To generate SSH key pair, specify `generate_admin_ssh_key = true`
  # To use existing key pair, specify `admin_ssh_key_data` to a valid SSH public key path.
  # Specify instance_count = 1 to create a single instance, or specify a higher number to create multiple instances  
  linux_distribution_name         = "ubuntu1805"
  virtual_machine_size            = var.size_linux_jumpbox
  admin_username                  = "azureadmin"
  disable_password_authentication = true
  generate_admin_ssh_key          = true
  instances_count                 = 1

  # Proxymity placement group, Availability Set and adding Public IP to VM's are optional.
  # remove these argument from module if you dont want to use it.  
  enable_proximity_placement_group = false
  enable_vm_availability_set       = false
  enable_public_ip_address         = false

  # Network Seurity group port allow definitions for each Virtual Machine
  # NSG association to be added automatically for all network interfaces.
  # Remove this NSG rules block, if `existing_network_security_group_id` is specified
  existing_network_security_group_id = module.mod_svcs_network.network_security_group_id

  # Boot diagnostics to troubleshoot virtual machines, by default uses managed 
  # To use custom storage account, specify `storage_account_name` with a valid name
  # Passing a `null` value will utilize a Managed Storage Account to store Boot Diagnostics
  enable_boot_diagnostics = false
  
  # Attach a managed data disk to a Windows/Linux VM's. Possible Storage account type are: 
  # `Standard_LRS`, `StandardSSD_ZRS`, `Premium_LRS`, `Premium_ZRS`, `StandardSSD_LRS`
  # or `UltraSSD_LRS` (UltraSSD_LRS only available in a region that support availability zones)
  # Initialize a new data disk - you need to connect to the VM and run diskmanagemnet or fdisk
  data_disks = {
    disk1 = {
      name                 = "gh_disk1"
      disk_size_gb         = 100
      lun                  = 0
      storage_account_type = "StandardSSD_LRS"
    }    
  }

  # (Optional) To enable Azure Monitoring and install log analytics agents
  # (Optional) Specify `storage_account_name` to save monitoring logs to storage.   
  log_analytics_resource_id = module.mod_operational_logging.laws_resource_id

  # Deploy log analytics agents to virtual machine. 
  # Log analytics workspace customer id and primary shared key required.
  deploy_log_analytics_agent                 = false

  // Tags
  extra_tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}
