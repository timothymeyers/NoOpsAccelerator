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

##############
### DATA   ###
##############
data "azurerm_client_config" "current" {}

##############################
### STAGE 0: Scaffolding   ###
##############################
// Resource Group for the Spoke
module "mod_dev_env_aks_workload_spoke_resource_group" {
  source = "../../../../../../terraform/core/modules/Microsoft.Resources/resourceGroups"
  //Global Settings
  location = var.location

  // Resource Group Parameters
  name = var.spoke_resource_group_name

  // Resource Group Locks
  enable_resource_locks = var.enable_resource_locks
  lock_level            = var.lock_level

  // Resource Group Tags
  tags = merge(var.tags, {
    DeployedBy = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}

###################################################
### STAGE 1: Build out workload spoke network   ###
###################################################

module "mod_dev_env_aks_workload_spoke_network" {
  depends_on = [
    module.mod_dev_env_aks_workload_spoke_resource_group
  ]
  providers = { azurerm = azurerm.dev_aks }
  source    = "../../../../../../terraform/core/overlays/hubspoke/spoke"

  // Global Settings
  location            = var.location
  resource_group_name = module.mod_dev_env_aks_workload_spoke_resource_group.name

  // Workload Spoke Configuration
  spoke_vnetname           = var.spoke_virtual_network_name
  spoke_vnet_address_space = var.spoke_spoke_vnet_address_space

  // Workload Spoke Subnets
  spoke_subnets                      = var.spoke_spoke_subnets
  spoke_network_security_group_name  = var.spoke_network_security_group_name
  spoke_network_security_group_rules = var.spoke_network_security_group_rules
  spoke_route_table_name             = var.spoke_route_table_name
  spoke_route_table_routes = [
    {
      name                   = "RouteToAzureFirewall"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = var.firewall_private_ip
    }
  ]

  // Loggging Settings
  spoke_log_storage_account_name       = var.spoke_log_storage_account_name
  spoke_logging_storage_account_config = var.spoke_logging_storage_account_config

  // Locks
  enable_resource_locks = var.enable_resource_locks
  lock_level            = var.lock_level

  // Tags
  tags = var.tags
}

####################################
## STAGE 2: Networking Peering   ###
####################################

# Peering between the Hub and Spoke Virtual Networks
module "mod_hub_to_spoke_networking_peering" {
  providers = { azurerm = azurerm.dev_aks }
  depends_on = [
    module.mod_dev_env_aks_workload_spoke_resource_group,
    module.mod_dev_env_aks_workload_spoke_network
  ]
  source = "../../../../../../terraform/core/overlays/hubSpoke/peering"

  count = var.peer_to_hub_virtual_network ? 1 : 0

  // Hub Networking Peering Settings
  peering_name_1_to_2 = "${var.hub_virtual_network_name}-to-${module.mod_dev_env_aks_workload_spoke_network.virtual_network_name}"
  vnet_1_id           = var.hub_virtual_network_id
  vnet_1_name         = var.hub_virtual_network_name
  vnet_1_rg           = var.hub_resource_group_name

  // Operations Networking Peering Settings
  peering_name_2_to_1 = "${module.mod_dev_env_aks_workload_spoke_network.virtual_network_name}-to-${var.hub_virtual_network_name}"
  vnet_2_id           = module.mod_dev_env_aks_workload_spoke_network.virtual_network_id
  vnet_2_name         = module.mod_dev_env_aks_workload_spoke_network.virtual_network_name
  vnet_2_rg           = module.mod_dev_env_aks_workload_spoke_network.resource_group_name

  // Settings
  allow_virtual_network_access = var.allow_virtual_network_access
  use_remote_gateways          = var.use_remote_gateways
}

######################################################################
### STAGE 3: Build out Azure Kubernetes Service with ACR & Jumpbox ###
######################################################################

module "dev_env_acr_aks_cluster" {
  depends_on = [
    module.mod_dev_env_aks_workload_spoke_resource_group,
    module.mod_dev_env_aks_workload_spoke_network,
    module.mod_hub_to_spoke_networking_peering
  ]
  providers = { azurerm = azurerm.dev_aks }
  source    = "../../../../../../terraform/core/overlays/azureKubernetesService"
  // Global Settings
  org_prefix          = var.required.org_prefix
  deploy_environment  = var.required.deploy_environment
  location            = var.location
  resource_group_name = module.mod_dev_env_aks_workload_spoke_resource_group.name

  // ACR Settings  
  enable_container_pull = var.enable_container_pull
  acr_pe_vnet_subnet_id = module.mod_dev_env_aks_workload_spoke_network.subnet_ids["privatelinks-snet"]
  acr_name              = var.acr_name
  acr_sku               = var.acr_sku
  acr_admin_enabled     = var.acr_admin_enabled
  acr_dns_virtual_networks_to_link = {
    ("privatelinks-snet") = {
      subscription_id      = data.azurerm_client_config.current.subscription_id
      resource_group_name  = module.mod_dev_env_aks_workload_spoke_resource_group.name
      virtual_network_name = module.mod_dev_env_aks_workload_spoke_network.virtual_network_name
    }
  }

  // AKS Cluster Settings
  aks_name                         = var.aks_prefix_name
  aks_node_pool_vnet_subnet_id     = module.mod_dev_env_aks_workload_spoke_network.subnet_ids["clusternodes-snet"]
  control_plane_kubernetes_version = var.control_plane_kubernetes_version
  sla_sku                          = var.sku_tier
  network_plugin                   = var.network_plugin
  net_profile_dns_service_ip       = var.net_profile_dns_service_ip
  net_profile_docker_bridge_cidr   = var.net_profile_docker_bridge_cidr
  net_profile_service_cidr         = var.net_profile_service_cidr
  net_profile_pod_cidr             = var.net_profile_pod_cidr
  agents_max_count                 = var.agents_max_count
  agents_min_count                 = var.agents_min_count
  private_cluster_enabled          = var.private_cluster_enabled
  identity_type                    = var.use_user_defined_identity ? "UserAssigned" : "SystemAssigned"

  // AKS Jumpbox Settings
  create_jumpbox              = true
  size_linux_jumpbox          = var.vm_size
  vm_os_disk_image            = var.vm_os_disk_image
  virtual_network_name        = module.mod_dev_env_aks_workload_spoke_network.virtual_network_name
  vm_subnet_id                = "default-snet"
  network_security_group_name = module.mod_dev_env_aks_workload_spoke_network.network_security_group_name

  // Tags
  tags = merge(var.tags, {
    DeployedBy = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}

####################################
### STAGE 5: Build out ComosDB   ###
####################################

/* module "dev_env_comosdb" {
} */

#######################################
### STAGE 5: Build out Resis Cache  ###
#######################################

/* module "dev_env_redis_cache" {
} */
