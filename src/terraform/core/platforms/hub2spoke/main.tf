# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module Example to deploy an SCCA Compliant Platform Hub/ 1 Spoke Landing Zone
DESCRIPTION: The following components will be options in this deployment
              * Hub Virtual Network (VNet)
              * Operations Network Artifacts (Optional)
              * Bastion Host (Optional)
              * DDos Standard Plan (Optional)
              * Microsoft Defender for Cloud (Optional)              
            * Spokes
              * Operations (Tier 1)
            * Logging
              * Azure Sentinel
              * Azure Log Analytics
            * Azure Firewall
            * Private DNS Zones - Details of all the Azure Private DNS zones can be found here --> [https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration](https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration)
AUTHOR/S: jspinella

IMPORTANT: This module is not intended to be used as a standalone module. It is intended to be used as a module within a Misson Enclave deployment. Please see the Mission Enclave documentation for more information.
*/

##############
### DATA   ###
##############
data "azurerm_client_config" "current_client" {}

################################
### STAGE 0: Scaffolding     ###
################################

// Resource Group for the Logging
module "mod_logging_resource_group" {
  providers = { azurerm = azurerm.logging }
  source    = "../../modules/Microsoft.Resources/resourceGroups"

  //Global Settings
  location = var.location

  // Resource Group Parameters
  name = local.loggingResourceGroupName

  // Resource Group Locks
  enable_resource_lock = var.enable_services.enable_resource_locks
  lock_level           = "CanNotDelete"

  // Resource Group Tags
  tags = merge(var.tags, {
    DeployedBy = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}

// Resource Group for the Hub
module "mod_hub_resource_group" {
  providers = { azurerm = azurerm.hub }
  depends_on = [
    module.mod_logging_resource_group
  ]
  source = "../../modules/Microsoft.Resources/resourceGroups"
  //Global Settings
  location = var.location

  // Resource Group Parameters
  name = local.hubResourceGroupName

  // Resource Group Locks
  enable_resource_lock = var.enable_services.enable_resource_locks
  lock_level           = "CanNotDelete"

  // Resource Group Tags
  tags = merge(var.tags, {
    DeployedBy = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}

// Resource Group for the Operations
module "mod_ops_resource_group" {
  depends_on = [
    module.mod_logging_resource_group
  ]
  providers = { azurerm = azurerm.ops }
  source    = "../../modules/Microsoft.Resources/resourceGroups"
  //Global Settings
  location = var.location

  // Resource Group Parameters
  name = local.opsResourceGroupName

  // Resource Group Locks
  enable_resource_lock = var.enable_services.enable_resource_locks
  lock_level           = "CanNotDelete"

  // Resource Group Tags
  tags = merge(var.tags, {
    DeployedBy = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}

// Resource Group for the Shared Services
module "mod_svcs_resource_group" {
  depends_on = [
    module.mod_logging_resource_group
  ]
  providers = { azurerm = azurerm.svcs }
  source    = "../../modules/Microsoft.Resources/resourceGroups"
  //Global Settings
  location = var.location

  // Resource Group Parameters
  name = local.svcsResourceGroupName

  // Resource Group Locks
  enable_resource_lock = var.enable_services.enable_resource_locks
  lock_level           = "CanNotDelete"

  // Resource Group Tags
  tags = merge(var.tags, {
    DeployedBy = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}

################################
### STAGE 1: Logging         ###
################################

// Logging
module "mod_logging" {
  depends_on = [
    module.mod_logging_resource_group
  ]
  providers = { azurerm = azurerm.logging }
  source    = "../../overlays/hubSpokeCore/vdms/logging"

  // Global Settings
  location            = var.location
  resource_group_name = module.mod_logging_resource_group.name

  // Logging Settings
  ops_logging_subid                = var.ops_subid
  ops_logging_log_analytics        = var.logging_log_analytics
  deploy_solutions                 = var.enable_services.deploy_laws_solutions
  deploy_sentinel                  = var.enable_services.deploy_sentinel
  logging_log_storage_account_name = local.loggingLogStorageAccountName
  log_analytics_workspace_name     = local.logAnalyticsWorkspaceName
  logging_storage_account          = var.logging_storage_account

  // Tags
  tags = var.tags # Tags to be applied to all resources

}

// Hub Central Logging
module "mod_hub_central_logging" {
  source = "../../modules/Microsoft.Insights/diagnosticSettings"

  // Log Analytics Parameters
  name                       = "log-hub-sub-activity-to-${module.mod_logging.laws_name}"
  target_resource_id         = "/subscriptions/${var.hub_subid}"
  log_analytics_workspace_id = module.mod_logging.laws_resource_id
  storage_account_id         = module.mod_networking_hub.storage_account_id

  logs = local.centrals_diagnostic_log_categories
}


// Operations Central Logging
module "mod_ops_central_logging" {
  count  = (var.ops_subid != "") ? (var.ops_subid != var.hub_subid ? 1 : 0) : 0
  source = "../../modules/Microsoft.Insights/diagnosticSettings"

  // Log Analytics Parameters
  name                       = "log-operations-sub-activity-to-${module.mod_logging.laws_name}"
  target_resource_id         = "/subscriptions/${var.ops_subid}"
  log_analytics_workspace_id = module.mod_logging.laws_resource_id
  storage_account_id         = module.mod_networking_operations.storage_account_id

  logs = local.centrals_diagnostic_log_categories
}

// Shared Services Central Logging
module "mod_svcs_central_logging" {
  count  = (var.svcs_subid != "") ? (var.svcs_subid != var.hub_subid ? 1 : 0) : 0
  source = "../../modules/Microsoft.Insights/diagnosticSettings"

  // Log Analytics Parameters
  name                       = "log-shared-services-sub-activity-to-${module.mod_logging.laws_name}"
  target_resource_id         = "/subscriptions/${var.svcs_subid}"
  log_analytics_workspace_id = module.mod_logging.laws_resource_id
  storage_account_id         = module.mod_networking_sharedServices.storage_account_id

  logs = local.centrals_diagnostic_log_categories
}

###################################
## STAGE 2: Hub Networking      ###
###################################

module "mod_networking_hub" {
  providers = { azurerm = azurerm.hub }
  depends_on = [
    module.mod_hub_resource_group
  ]
  source = "../../overlays/hubSpokeCore/vdss/hub"

  // Global Settings

  org_prefix          = var.required.org_prefix
  location            = var.location
  deploy_environment  = var.required.deploy_environment
  resource_group_name = module.mod_hub_resource_group.name

  // Hub Logging Settings
  hub_log_storage_account_name = local.hubLogStorageAccountName
  log_analytics_resource_id    = module.mod_logging.laws_resource_id
  log_analytics_workspace_id   = module.mod_logging.laws_workspace_id
  log_analytics_storage_id     = module.mod_logging.laws_StorageAccount_Id

  // Hub Networking Settings
  hub_virtual_network_name                       = local.hubVirtualNetworkName
  hub_vnet_address_space                         = var.hub_vnet_address_space
  hub_subnet_name                                = local.hubSubnetName
  hub_route_table_name                           = local.hubRouteTableName
  hub_network_security_group_name                = local.hubNetworkSecurityGroupName
  hub_virtual_network_diagnostics_logs           = var.hub_virtual_network_diagnostics_logs
  hub_network_security_group_diagnostics_metrics = var.hub_virtual_network_diagnostics_metrics
  hub_network_security_group_diagnostics_logs    = var.hub_network_security_group_diagnostics_logs
  hub_virtual_network_diagnostics_metrics        = var.hub_virtual_network_diagnostics_metrics
  hub_subnet_service_endpoints                   = var.hub_subnet_service_endpoints

  // Hub Firewall Settings
  firewall_private_ip = module.mod_networking_hub_firewall.private_ip

  // Hub Resource Locks
  enable_resource_locks = var.enable_services.enable_resource_locks

  // Tags
  tags = var.tags # Tags to be applied to all resources

}


######################################
### STAGE 2.1: Network Artifacts   ###
######################################

##############################################################################
### This stage is optional based on the value of `create_network_artifacts` ##
##############################################################################

module "mod_network_artifacts" {
  providers = { azurerm = azurerm.ops }
  source    = "../../overlays/hubSpokeCore/vdss/networkArtifacts"

  // Global Settings
  location            = var.location
  resource_group_name = local.netartResourceGroupName
  org_prefix          = var.required.org_prefix
  tenant_id           = data.azurerm_client_config.current_client.tenant_id
  object_id           = data.azurerm_client_config.current_client.object_id
  deploy_environment  = var.required.deploy_environment
  vnet_subnet_id      = module.mod_networking_operations.subnet_ids[local.opsSubnetName]

  // Network Artifacts Settings
  enable_network_artifacts = var.enable_services.enable_network_artifacts # Enable Network Artifacts

  // Network Artifacts storage account
  netart_log_storage_account_name = local.netartLogStorageAccountName # Network Artifacts Storage Account Name

  // Network Artifacts Key Vault
  netart_key_vault_name           = local.netartKeyVaultName
  sku_name                        = var.kv_sku_name
  soft_delete_retention_days      = var.kv_soft_delete_retention_days
  purge_protection_enabled        = var.kv_purge_protection_enabled
  enabled_for_deployment          = var.kv_enabled_for_deployment
  enabled_for_disk_encryption     = var.kv_enabled_for_disk_encryption
  enabled_for_template_deployment = var.kv_enabled_for_template_deployment
  enable_rbac_authorization       = var.kv_enable_rbac_authorization

  // Logging Settings
  log_analytics_resource_id  = var.enable_network_artifacts_diagnostics ? module.mod_logging.laws_resource_id : null
  log_analytics_workspace_id = var.enable_network_artifacts_diagnostics ? module.mod_logging.laws_workspace_id : null
  log_analytics_storage_id   = var.enable_network_artifacts_diagnostics ? module.mod_logging.laws_StorageAccount_Id : null

  // Tags
  tags = var.tags # Tags to be applied to all resources # Tags to be applied to all resources
}

##############################################
## STAGE 2: Hub Networking - Firewall      ###
##############################################

module "mod_networking_hub_firewall" {
  providers = { azurerm = azurerm.hub }
  depends_on = [
    module.mod_hub_resource_group
  ]

  source = "../../overlays/hubSpokeCore/vdss/firewall"

  // Global Settings
  org_prefix           = var.required.org_prefix
  location             = var.location
  deploy_environment   = var.required.deploy_environment
  resource_group_name  = module.mod_hub_resource_group.name
  virtual_network_name = module.mod_networking_hub.virtual_network_name

  // Firewall Settings
  firewall_name                              = local.firewallName
  firewall_management_public_ip_address_name = local.firewallManagementPublicIPAddressName
  firewall_client_public_ip_address_name     = local.firewallClientPublicIPAddressName
  firewall_policy_name                       = local.firewallPolicyName
  enable_firewall                            = var.enable_services.enable_firewall

  // Firewall Policy Settings
  enable_forced_tunneling = var.enable_services.enable_forced_tunneling # Enable Forced Tunneling

  // Firewall Logging Settings
  log_analytics_resource_id            = var.enable_services.enable_firewall ? module.mod_logging.laws_resource_id : null
  log_analytics_workspace_id           = var.enable_services.enable_firewall ? module.mod_logging.laws_workspace_id : null
  log_analytics_storage_id             = var.enable_services.enable_firewall ? module.mod_logging.laws_StorageAccount_Id : null
  publicIP_address_diagnostics_logs    = var.publicIP_address_diagnostics_logs
  publicIP_address_diagnostics_metrics = var.publicIP_address_diagnostics_metrics

  // Firewall Resource Locks
  enable_resource_locks = var.enable_services.enable_resource_locks

  // Tags
  tags = var.tags # Tags to be applied to all resources # Tags to be applied to all resources

}

##########################################
## STAGE 4: Operations Networking      ###
##########################################

module "mod_networking_operations" {
  providers = { azurerm = azurerm.ops }
  depends_on = [
    module.mod_ops_resource_group,
    module.mod_networking_hub_firewall
  ]
  source = "../../overlays/hubSpokeCore/vdms/operations"

  // Global Settings

  org_prefix          = var.required.org_prefix
  location            = var.location
  deploy_environment  = var.required.deploy_environment
  resource_group_name = module.mod_ops_resource_group.name

  // Logging Settings
  log_analytics_resource_id  = module.mod_logging.laws_resource_id
  log_analytics_workspace_id = module.mod_logging.laws_workspace_id
  log_analytics_storage_id   = module.mod_logging.laws_StorageAccount_Id

  // Operations Networking Settings
  ops_virtual_network_name        = local.opsVirtualNetworkName
  ops_vnet_address_space          = var.ops_vnet_address_space
  ops_log_storage_account_name    = local.opsLogStorageAccountName
  ops_subnet_name                 = local.opsSubnetName
  ops_network_security_group_name = local.opsNetworkSecurityGroupName
  firewall_private_ip             = module.mod_networking_hub_firewall.private_ip

  // Operations Network Security Group Rules
  ops_network_security_group_rules = var.ops_network_security_group_rules

  // Operations Resource Locks
  enable_resource_locks = var.enable_services.enable_resource_locks

  // Tags
  tags = var.tags # Tags to be applied to all resources# Tags to be applied to all resources
}

############################################
## STAGE 5: Shared Services Networking   ###
############################################

module "mod_networking_sharedServices" {
  providers = { azurerm = azurerm.svcs }
  depends_on = [
    module.mod_svcs_resource_group,
    module.mod_networking_hub_firewall
  ]
  source = "../../overlays/hubSpokeCore/vdms/sharedServices"

  // Global Settings

  org_prefix          = var.required.org_prefix
  location            = var.location
  deploy_environment  = var.required.deploy_environment
  resource_group_name = module.mod_svcs_resource_group.name

  // Logging Settings
  log_analytics_resource_id  = module.mod_logging.laws_resource_id
  log_analytics_workspace_id = module.mod_logging.laws_workspace_id
  log_analytics_storage_id   = module.mod_logging.laws_StorageAccount_Id

  // Shared Services Networking Settings
  svcs_virtual_network_name        = local.svcsVirtualNetworkName
  svcs_vnet_address_space          = var.svcs_vnet_address_space
  svcs_vnet_subnet_address_space   = var.svcs_vnet_subnet_address_space
  svcs_log_storage_account_name    = local.svcsLogStorageAccountName
  svcs_subnet_name                 = local.svcsSubnetName
  svcs_network_security_group_name = local.svcsNetworkSecurityGroupName
  firewall_private_ip              = module.mod_networking_hub_firewall.private_ip

  // Shared Services Network Security Group Rules
  svcs_network_security_group_rules = var.svcs_network_security_group_rules

  // Shared Services Resource Locks
  enable_resource_locks = var.enable_services.enable_resource_locks

  // Tags
  tags = var.tags # Tags to be applied to all resources# Tags to be applied to all resources
}

####################################
## STAGE 6: Networking Peering   ###
####################################

module "mod_hub_to_ops_networking_peering" {
  depends_on = [
    module.mod_networking_hub,
    module.mod_networking_operations
  ]
  source = "../../overlays/hubSpokeCore/peering"

  count = var.peer_to_hub_virtual_network == false ? 0 : 1

  // Hub Networking Peering Settings
  peering_name_1_to_2 = "${module.mod_networking_hub.virtual_network_name}-to-${module.mod_networking_operations.virtual_network_name}"
  vnet_1_id           = module.mod_networking_hub.virtual_network_id
  vnet_1_name         = module.mod_networking_hub.virtual_network_name
  vnet_1_rg           = module.mod_hub_resource_group.name

  // Operations Networking Peering Settings
  peering_name_2_to_1 = "${module.mod_networking_operations.virtual_network_name}-to-${module.mod_networking_hub.virtual_network_name}"
  vnet_2_id           = module.mod_networking_operations.virtual_network_id
  vnet_2_name         = module.mod_networking_operations.virtual_network_name
  vnet_2_rg           = module.mod_ops_resource_group.name

  // Settings
  allow_virtual_network_access = var.allow_virtual_network_access
  use_remote_gateways          = var.use_remote_gateways
}

module "mod_hub_to_svcs_networking_peering" {
  depends_on = [
    module.mod_networking_hub,
    module.mod_networking_sharedServices
  ]
  source = "../../overlays/hubSpokeCore/peering"

  count = var.peer_to_hub_virtual_network == false ? 0 : 1

  // Hub Networking Peering Settings
  peering_name_1_to_2 = "${module.mod_networking_hub.virtual_network_name}-to-${module.mod_networking_sharedServices.virtual_network_name}"
  vnet_1_id           = module.mod_networking_hub.virtual_network_id
  vnet_1_name         = module.mod_networking_hub.virtual_network_name
  vnet_1_rg           = module.mod_hub_resource_group.name

  // Shared Services Networking Peering Settings
  peering_name_2_to_1 = "${module.mod_networking_sharedServices.virtual_network_name}-to-${module.mod_networking_hub.virtual_network_name}"
  vnet_2_id           = module.mod_networking_sharedServices.virtual_network_id
  vnet_2_name         = module.mod_networking_sharedServices.virtual_network_name
  vnet_2_rg           = module.mod_svcs_resource_group.name

  // Settings
  allow_virtual_network_access = var.allow_virtual_network_access
  use_remote_gateways          = var.use_remote_gateways
}

########################################
### STAGE 7: Azure Security Center   ###
########################################

module "mod_azure_security_center" {
  providers  = { azurerm = azurerm.hub }
  depends_on = [module.mod_networking_hub]
  source     = "../../modules/Microsoft.Security/azureSecurityCenter"

  count = var.enable_services.enable_azure_security_center ? 1 : 0

  # Logging Resource Group, location, log analytics details
  resource_group_name          = module.mod_logging_resource_group.name
  log_analytics_workspace_name = module.mod_logging.laws_name
  environment                  = var.environment

  # Enable Security Center API Setting
  enable_security_center_setting = var.enable_services.enable_security_center_setting
  security_center_setting_name   = "MCAS"

  # Enable auto provision of log analytics agents on VM's if they doesn't exist. 
  enable_security_center_auto_provisioning = "On"

  # Subscription Security Center contacts
  # One or more email addresses seperated by commas not supported by Azure proivider currently
  security_center_contacts = {
    email               = "abc@xyz.com"   # must be a valid email address
    phone               = "+919010910910" # Optional
    alert_notifications = true
    alerts_to_admins    = true
  }
}

################################
### STAGE 8: Remote Access   ###
################################

#########################################################################
### This stage is optional based on the value of `create_bastion_host`
#########################################################################

module "mod_bastion_host" {
  providers  = { azurerm = azurerm.hub }
  depends_on = [module.mod_networking_hub]
  source     = "../../overlays/bastion"

  // Global Settings
  org_prefix          = var.required.org_prefix
  resource_group_name = module.mod_hub_resource_group.name
  location            = var.location

  // Bastion Host Settings
  virtual_network_name             = module.mod_networking_hub.virtual_network_name
  subnet_id                        = module.mod_networking_hub.subnet_ids[local.hubSubnetName]
  network_security_group_name      = module.mod_networking_hub.network_security_group_name
  bastion_host_name                = var.bastion_host_name
  bastion_address_space            = var.bastion_address_space
  bastion_subnet_service_endpoints = var.bastion_subnet_service_endpoints

  // Bastions Diagnostics Settings
  enable_bastion_diagnostics       = var.enable_services.enable_bastion_diagnostics
  log_analytics_storage_account_id = module.mod_logging.laws_StorageAccount_Id

  // Jumpbox Settings
  admin_username              = var.jumpbox_admin_username # The admin username for the jumpbox
  use_random_password         = var.use_random_password    # If true, a random password will be generated and stored in the Azure Key Vault
  size_jumpbox                = var.size_jumpbox
  log_analytics_workspace_id  = module.mod_logging.laws_resource_id
  log_analytics_workspace_key = module.mod_logging.laws_workspace_key

  // Linux Jumpbox Settings
  create_bastion_linux_jumpbox = var.enable_services.bastion_linux_virtual_machines # If true, a Linux jumpbox will be created
  vm_os_linux_disk_image       = var.jumpbox_linux_os_disk_image

  // Windows Jumpbox Settings
  create_bastion_windows_jumpbox = var.enable_services.bastion_windows_virtual_machines # If true, a Windows jumpbox will be created
  vm_os_windows_disk_image       = var.jumpbox_windows_os_disk_image

  // Tags
  tags = var.tags # Tags to be applied to all resources
}



