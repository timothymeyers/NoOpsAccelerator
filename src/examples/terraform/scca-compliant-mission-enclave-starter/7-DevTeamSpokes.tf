# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module to deploy the Development Workload Environent Network 
DESCRIPTION: The following components will be options in this deployment
              Development Team Environent Spoke Virtual Network (Vnet)
              Subnets
              Route Table
              Network Security Group
              Log Storage 
              Azure Key Vault
              Azure Kubernetes Service (AKS)
              Azure Container Registry (ACR)                          
              Private DNS Zones - Details of all the Azure Private DNS zones can be found here --> https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration
AUTHOR/S: jspinella
*/

#################################################
### STAGE 7: Dev Teams Network Configuations ###
#################################################

# Dev Team Environment Spokes Network (Optional). 
# This is the network for the Dev Team 1 environment. 
# This is a spoke network that is peered to the hub network. 
# This could be updated to use a object to create multiple spoke networks.
 /*module "mod_dev_team1_env_spoke_network" {
  for_each = toset(var.locations) # for each needs a set, cannot work with a list
  source   = "./support/workloads/devEnvSpoke"

  # General Settings
  environment            = var.environment
  metadata_host          = var.metadata_host  
  location               = each.value
  required               = var.required

  // Resource Group Settings
  wl_resource_group_name = local.dev1ResourceGroupName

  // Subscription Settings
  hub_subscription_id = var.hub_subscription_id
  wl_subscription_id  = var.dev1_subscription_id

  # Network Settings
  wl_virtual_network_name           = local.dev1VirtualNetworkName
  wl_spoke_vnet_address_space       = var.dev1_spoke_vnet_address_space
  wl_network_security_group_name    = local.dev1NetworkSecurityGroupName
  wl_route_table_name               = local.dev1RouteTableName
  wl_spoke_subnets                  = var.dev1_spoke_subnets
  wl_network_security_group_rules   = var.dev1_network_security_group_rules
  wl_log_storage_account_name       = local.dev1LogStorageAccountName
  wl_logging_storage_account_config = var.dev1_logging_storage_account_config

  // Network Peering Configuration
  peer_to_hub_virtual_network  = var.peer_to_hub_virtual_network
  allow_virtual_network_access = var.allow_virtual_network_access
  use_remote_gateways          = var.use_remote_gateways

  // Firewall Settings
  firewall_private_ip = module.mod_landingzone_hub2spoke.firewall_private_ip_address
  firewall_public_ip  = module.mod_landingzone_hub2spoke.firewall_public_ip_address

  // Hub Settings
  hub_virtual_network_id   = module.mod_landingzone_hub2spoke.hub_vnet_id
  hub_virtual_network_name = module.mod_landingzone_hub2spoke.hub_vnetname
  hub_resource_group_name  = module.mod_landingzone_hub2spoke.hub_rgname

  // AKS Settings
  aks_prefix_name           = local.dev1ShortName
  use_user_defined_identity = var.use_user_defined_identity

  // ACR Settings
  acr_name = local.dev1ContainerRegName
  acr_sku  = var.acr_sku

  // Locks
  enable_resource_locks = var.enable_services.enable_resource_locks

  // Tags
  tags = merge(var.tags, {
    DeployedBy = format("AzureNoOpsTF [%s]", terraform.workspace)
  }) # Tags to be applied to all resources
} */
