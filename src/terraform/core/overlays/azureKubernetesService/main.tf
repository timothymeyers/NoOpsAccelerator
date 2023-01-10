# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module to deploy a Azure Kubernetes Private Cluster workload with Linux Jump Boxes to an Network
DESCRIPTION: The following components will be options in this deployment
              * Azure Container Registry
              * Azure Kubernetes Cluster
              * Azure Kubernetes Cluster Node Pool
              * Linux VM
AUTHOR/S: jspinella
*/

// Create the Azure Container Registry
module "aks_cluster_container_registry" {
  count                        = var.enable_container_pull == true ? 1 : 0
  source                       = "../azureContainerRegistry"
  acr_name                     = var.acr_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  vnet_subnet_id               = var.vnet_subnet_id
  acr_sku                      = var.acr_sku
  acr_admin_enabled            = var.acr_admin_enabled
  log_analytics_workspace_id   = var.log_analytics_workspace_id
  log_analytics_retention_days = var.log_analytics_retention_days
}

// Create the Azure Kubernetes Cluster
module "aks_cluster" {
  source                                   = "../../modules/Microsoft.ContainerService"
  name                                     = var.aks_cluster_name
  location                                 = var.location
  resource_group_name                      = var.resource_group_name
  kubernetes_version                       = var.kubernetes_version
  dns_prefix                               = lower(var.dns_prefix == "" ? var.aks_cluster_name : var.dns_prefix)
  private_cluster_enabled                  = var.private_cluster_enabled
  automatic_channel_upgrade                = var.automatic_channel_upgrade
  sku_tier                                 = var.sku_tier
  default_node_pool_name                   = var.default_node_pool_name
  default_node_pool_vm_size                = var.default_node_pool_vm_size
  vnet_subnet_id                           = var.default_node_pool_subnet_name == "" ? var.vnet_subnet_id : null
  default_node_pool_enable_auto_scaling    = var.default_node_pool_enable_auto_scaling
  default_node_pool_enable_host_encryption = var.default_node_pool_enable_host_encryption
  default_node_pool_enable_node_public_ip  = var.default_node_pool_enable_node_public_ip
  default_node_pool_max_count              = var.default_node_pool_max_count
  default_node_pool_min_count              = var.default_node_pool_min_count
  default_node_pool_node_count             = var.default_node_pool_node_count
  default_node_pool_os_disk_type           = var.default_node_pool_os_disk_type
  network_docker_bridge_cidr               = var.network_docker_bridge_cidr
  network_dns_service_ip                   = var.network_dns_service_ip
  network_plugin                           = var.network_plugin
  outbound_type                            = "userDefinedRouting"
  network_service_cidr                     = var.network_service_cidr
  log_analytics_workspace_id               = module.log_analytics_workspace.id
  role_based_access_control_enabled        = var.role_based_access_control_enabled
  tenant_id                                = data.azurerm_client_config.current.tenant_id
  admin_group_object_ids                   = var.admin_group_object_ids
  azure_rbac_enabled                       = var.azure_rbac_enabled
  admin_username                           = var.admin_username
  ssh_public_key                           = var.ssh_public_key
}

// Create the Azure Kubernetes Cluster Network
module "network_contributor" {
  source                           = "../../modules/Microsoft.Authorization/roleAssignment"
  scope                            = data.azurerm_resource_group.aks_rg.id
  role_definition_name             = "Network Contributor"
  mode                             = "built-in"
  principal_id                     = module.aks_cluster.aks_identity_principal_id
  skip_service_principal_aad_check = true
}

// Create the Azure Kubernetes Cluster Network
module "acr_pull" {
  source                           = "../../modules/Microsoft.Authorization/roleAssignment"
  count                            = var.enable_container_pull ? 1 : 0
  role_definition_name             = "AcrPull"
  mode                             = "built-in"
  scope                            = module.container_registry.id
  principal_id                     = module.aks_cluster.kubelet_identity_object_id
  skip_service_principal_aad_check = true
}

// Create the Azure Kubernetes Cluster Jumpbox
module "aks_cluster_virtual_machine" {
  source = "../virtualMachine/linux"

  // Global Settings
  resource_group_name  = data.azurerm_resource_group.hub.name
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
