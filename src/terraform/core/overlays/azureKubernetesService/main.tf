# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module to deploy a Azure Kubernetes Private Cluster workload with Linux Jump Boxes to an Network
DESCRIPTION: The following components will be options in this deployment
              * Azure Container Registry
              * Azure Kubernetes Cluster
              * Azure Kubernetes Cluster Node Pool
              * Linux VM Jumpbox
AUTHOR/S: jspinella
*/

// Create the Azure Container Registry
module "aks_cluster_container_registry" {
  count               = var.enable_container_pull ? 1 : 0
  source              = "../azureContainerRegistry"
  acr_name            = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  vnet_subnet_id      = var.acr_pe_vnet_subnet_id
  acr_sku             = var.acr_sku
  acr_admin_enabled   = var.acr_admin_enabled
  virtual_networks_to_link = var.acr_dns_virtual_networks_to_link
}

# Assign the ACR Pull role to the AKS cluster   
resource "azurerm_role_assignment" "acr_pull" {
  count                            = var.enable_container_pull ? 1 : 0
  scope                            = module.aks_cluster_container_registry.0.id
  role_definition_name             = "AcrPull"
  principal_id                     = module.aks_cluster.kubelet_identity_object_id
  skip_service_principal_aad_check = true
}

# Create the AKS identity
resource "azurerm_user_assigned_identity" "aks_identity" {
  name                = "${local.clusterName}-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
}

// Create the Azure Kubernetes Cluster
module "aks_cluster" {
  source = "../../modules/Microsoft.ContainerService"

  prefix                          = local.clusterName
  resource_group_name             = var.resource_group_name
  location                        = var.location
  admin_username                  = null
  azure_policy_enabled            = true
  kubernetes_version              = var.control_plane_kubernetes_version
  node_resource_group             = "${var.resource_group_name}-worker"
  sku_tier                        = var.sla_sku
  api_server_authorized_ip_ranges = var.api_auth_ips
  microsoft_defender_enabled      = var.microsoft_defender_enabled
  vnet_subnet_id                  = var.aks_node_pool_vnet_subnet_id
  //disk_encryption_set_id = azurerm_disk_encryption_set.des.id
  #checkov:skip=CKV_AZURE_4:The logging is turn off for demo purpose. DO NOT DO THIS IN PRODUCTION ENVIRONMENT!
  log_analytics_workspace_enabled   = false
  enable_auto_scaling               = true
  network_plugin                    = var.network_plugin
  net_profile_dns_service_ip        = var.net_profile_dns_service_ip
  net_profile_docker_bridge_cidr    = var.net_profile_docker_bridge_cidr
  net_profile_pod_cidr              = var.net_profile_pod_cidr
  net_profile_service_cidr          = var.net_profile_service_cidr
  agents_max_count                  = var.agents_max_count
  agents_min_count                  = var.agents_min_count
  private_cluster_enabled           = true
  rbac_aad_managed                  = true
  role_based_access_control_enabled = true
  identity_type                     = var.identity_type
  identity_ids                      = ["${azurerm_user_assigned_identity.aks_identity.id}"]
  tags                              = var.tags
}

# Lookup the AKS resource group
data "azurerm_resource_group" "aks_rg" {
  name = var.resource_group_name
}

# Create a role assignment for the AKS cluster to be able to manage resources in the resource group
resource "azurerm_role_assignment" "aks_contributor" {
  scope                = data.azurerm_resource_group.aks_rg.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
}

// Create the Azure Kubernetes Cluster Jumpbox
/* module "aks_cluster_virtual_machine" {
  source = "../virtualMachine/linux"
  count                            = var.create_jumpbox ? 1 : 0

  // Global Settings
  resource_group_name  = var.resource_group_name
  location             = var.location
  virtual_network_name = var.virtual_network_name

  // Jumpbox Settings
  vm_name                     = local.linuxVmName
  subnet_name                 = var.subnet_id
  network_interface_name      = local.linuxNetworkInterfaceName
  ip_configuration_name       = local.linuxNetworkInterfaceIpConfigurationName
  network_security_group_name = var.network_security_group_name

  // OS Settings
  size           = var.size_linux_jumpbox
  admin_username = var.admin_username
  admin_password = var.use_random_password ? null : var.admin_password

  // OS Image Settings
  vm_os_disk_image = var.vm_os_disk_image

  // key vault
  use_key_vault               = var.use_key_vault
  log_analytics_workspace_id  = var.log_analytics_workspace_id
  log_analytics_workspace_key = var.log_analytics_workspace_key

  // Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Linux VM for Azure AKS %s", local.linuxVmName)
  })
}

 */
