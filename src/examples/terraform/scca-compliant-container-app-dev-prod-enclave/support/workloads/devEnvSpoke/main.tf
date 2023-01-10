# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module to deploy the Development Workload Environent Network 
DESCRIPTION: The following components will be options in this deployment
              Development Environent Spoke Virtual Network (Vnet)
              Subnets
              Route Table
              Network Security Group
              Log Storage 
              Azure Key Vault
              Azure Kubernetes Service (AKS)
              Azure Container Registry (ACR)
              Cosmos DB
              Redis Cache              
              Private DNS Zones - Details of all the Azure Private DNS zones can be found here --> https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration
AUTHOR/S: jspinella
*/

###################################################
### STAGE 1: Build out workload spoke network   ###
###################################################

module "dev_env_aks_workload_spoke_network" {
  source = "../../../../../../terraform/core/overlays/hubspoke/spoke"

  // Global Settings
  location            = var.location
  resource_group_name = var.wl_resource_group_name

  // Firewall
  firewall_private_ip_address = var.firewall_private_ip

  // Operations Spoke Configuration
  spoke_vnetname           = var.wl_virtual_network_name
  spoke_vnet_address_space = var.wl_spoke_vnet_address_space

  // Operations Spoke Subnets
  spoke_subnets                     = var.wl_spoke_subnets
  spoke_network_security_group_name = var.wl_network_security_group_name
  spoke_route_table_name            = var.wl_route_table_name

  // Loggging Settings
  spoke_log_storage_account_name       = var.wl_log_storage_account_name
  spoke_logging_storage_account_config = var.wl_logging_storage_account_config

  // Locks
  enable_resource_locks = var.enable_resource_locks
  lock_level            = var.lock_level

  // Tags
  tags = var.tags
}

####################################
## STAGE 2: Networking Peering   ###
####################################

# Peering between the Hub and Spoke

module "mod_hub_to_wl_networking_peering" {
  depends_on = [
    module.dev_env_aks_workload_spoke_network
  ]
  source = "../../../../../../terraform/core/overlays/hubSpoke/peering"

  count = var.peer_to_hub_virtual_network ? 1 : 0

  // Hub Networking Peering Settings
  peering_name_1_to_2 = "${var.hub_virtual_network_name}-to-${module.dev_env_aks_workload_spoke_network.virtual_network_name}"
  vnet_1_id           = var.hub_virtual_network_id
  vnet_1_name         = var.hub_virtual_network_name
  vnet_1_rg           = var.hub_resource_group_name

  // Operations Networking Peering Settings
  peering_name_2_to_1 = "${module.dev_env_aks_workload_spoke_network.virtual_network_name}-to-${var.hub_virtual_network_name}"
  vnet_2_id           = module.dev_env_aks_workload_spoke_network.virtual_network_id
  vnet_2_name         = module.dev_env_aks_workload_spoke_network.virtual_network_name
  vnet_2_rg           = module.dev_env_aks_workload_spoke_network.resource_group_name

  // Settings
  allow_virtual_network_access = var.allow_virtual_network_access
  use_remote_gateways          = var.use_remote_gateways
}

######################################################################
### STAGE 3: Build out Azure Kubernetes Service with ACR & Jumpbox ###
######################################################################

/* module "dev_env_acr_aks_cluster" {
  source = "../../overlays/azureKubernetesService"

  // Global Settings
  location            = var.location
  resource_group_name = module.mod_dev_env_workload_resource_group.name
  vnet_subnet_id      = module.dev_env_aks_workload_network.subnet_ids[var.default_node_pool_subnet_name]

  // Logging Settings
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.laws.id

  // ACR Settings
  acr_name                     = var.acr_name
  acr_sku                      = var.acr_sku
  acr_admin_enabled            = var.acr_admin_enabled

  // ACR Networking Settings
  virtual_networks_to_link = {
    (var.hub_network_name) = {
      subscription_id     = var.subscription_id
      resource_group_name = var.hub_network_rgname
    }
    (module.dev_env_aks_workload_network.name) = {
      subscription_id     = var.subscription_id
      resource_group_name = module.mod_dev_env_workload_resource_group.name
    }
  }

  // AKS Settings
  aks_cluster_name          = var.aks_cluster_name
  kubernetes_version        = var.kubernetes_version
  dns_prefix                = lower(var.aks_cluster_name)
  private_cluster_enabled   = true
  automatic_channel_upgrade = var.automatic_channel_upgrade
  sku_tier                  = var.sku_tier
  enable_container_pull    = var.enable_container_pull

  // AKS Network Settings
  network_docker_bridge_cidr = var.network_docker_bridge_cidr
  network_dns_service_ip     = var.network_dns_service_ip
  network_plugin             = var.network_plugin
  outbound_type              = "userDefinedRouting"
  network_service_cidr       = var.network_service_cidr

  // AKS Node Pool Settings
  default_node_pool_name                   = var.default_node_pool_name
  default_node_pool_vm_size                = var.default_node_pool_vm_size
  default_node_pool_availability_zones     = var.default_node_pool_availability_zones
  default_node_pool_node_labels            = var.default_node_pool_node_labels
  default_node_pool_node_taints            = var.default_node_pool_node_taints
  default_node_pool_enable_auto_scaling    = var.default_node_pool_enable_auto_scaling
  default_node_pool_enable_host_encryption = var.default_node_pool_enable_host_encryption
  default_node_pool_enable_node_public_ip  = var.default_node_pool_enable_node_public_ip
  default_node_pool_max_pods               = var.default_node_pool_max_pods
  default_node_pool_max_count              = var.default_node_pool_max_count
  default_node_pool_min_count              = var.default_node_pool_min_count
  default_node_pool_node_count             = var.default_node_pool_node_count
  default_node_pool_os_disk_type           = var.default_node_pool_os_disk_type

  // AKS RBAC Settings
  role_based_access_control_enabled = var.role_based_access_control_enabled
  admin_group_object_ids            = var.admin_group_object_ids
  azure_rbac_enabled                = var.azure_rbac_enabled

  // AKS Jumpbox Settings
  subnet_id                   = module.dev_env_aks_workload_network.subnet_ids[var.default_node_pool_subnet_name]
  network_security_group_name = module.dev_env_aks_workload_network.nsg_name
  size_linux_jumpbox          = var.size_linux_jumpbox
  admin_username              = var.admin_username
  use_random_password         = var.use_random_password
  vm_os_disk_image            = var.vm_os_disk_image
  use_key_vault               = var.use_key_vault

  // Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Private Kubernetes Cluster %s", local.aks_cluster_name)
  })
}

// Create additional node pool
module "dev_env_aks_node_pool" {
  source                 = "../../modules/Microsoft.ContainerService/node_pool"
  resource_group_name    = module.mod_dev_env_workload_resource_group.name
  kubernetes_cluster_id  = module.dev_env_acr_aks_cluster.id
  name                   = var.additional_node_pool_name
  vm_size                = var.additional_node_pool_vm_size
  mode                   = var.additional_node_pool_mode
  node_labels            = var.additional_node_pool_node_labels
  node_taints            = var.additional_node_pool_node_taints
  availability_zones     = var.additional_node_pool_availability_zones
  vnet_subnet_id         = module.aks_network.subnet_ids[var.additional_node_pool_subnet_name]
  enable_auto_scaling    = var.additional_node_pool_enable_auto_scaling
  enable_host_encryption = var.additional_node_pool_enable_host_encryption
  enable_node_public_ip  = var.additional_node_pool_enable_node_public_ip
  orchestrator_version   = var.kubernetes_version
  max_pods               = var.additional_node_pool_max_pods
  max_count              = var.additional_node_pool_max_count
  min_count              = var.additional_node_pool_min_count
  node_count             = var.additional_node_pool_node_count
  os_type                = var.additional_node_pool_os_type
  priority               = var.additional_node_pool_priority

  // Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Node Pool for Azure Kubernetes Cluster %s", local.aks_cluster_name)
  })
}

# Create a role assignment for the AKS cluster to be able to manage resources in the resource group
resource "azurerm_role_assignment" "network_contributor" {
  scope                            = module.mod_dev_env_workload_resource_group.id
  role_definition_name             = "Network Contributor"
  principal_id                     = module.dev_env_acr_aks_cluster.aks_identity_principal_id
  skip_service_principal_aad_check = true
} */


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
