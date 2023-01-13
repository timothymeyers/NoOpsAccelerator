# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module Example to deploy an SCCA Compliant Platform Hub/Spoke Landing Zone
DESCRIPTION: The following components will be options in this deployment
              * Hub Virtual Network (VNet)
              * Operations Network Artifacts (Optional)
              * Bastion Host (Optional)
              * DDos Standard Plan (Optional)
              * Microsoft Defender for Cloud (Optional)              
            * Spokes              
              * Operations (Tier 1)
              * Shared Services (Tier 2)
            * Logging
              * Azure Sentinel
              * Azure Log Analytics
            * Azure Firewall
            * Private DNS Zones - Details of all the Azure Private DNS zones can be found here --> [https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration](https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration)
AUTHOR/S: jspinella
IMPORTANT: This module is not intended to be used as a standalone module. It is intended to be used as a module within a Misson Enclave deployment. Please see the Mission Enclave documentation for more information.
*/

##################
### DATA       ###
##################
# Azure Provider
data "azurerm_subscription" "primary" {}
data "azurerm_client_config" "current_client" {}

################################
### STAGE 0: Scaffolding     ###
################################

// Resource Group for the Logging
module "mod_logging_resource_group" {
  providers = { azurerm = azurerm.ops }
  source    = "../../../../../terraform/core/modules/Microsoft.Resources/resourceGroups"

  //Global Settings
  location = var.location

  // Resource Group Parameters
  name = var.logging_resource_group_name

  // Resource Group Locks
  enable_resource_locks = var.enable_resource_locks
  lock_level            = var.lock_level

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
  source = "../../../../../terraform/core/modules/Microsoft.Resources/resourceGroups"

  //Global Settings
  location = var.location

  // Resource Group Parameters
  name = var.hub_resource_group_name

  // Resource Group Locks
  enable_resource_locks = var.enable_resource_locks
  lock_level            = var.lock_level

  // Resource Group Tags
  tags = merge(var.tags, {
    DeployedBy = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}

// Resource Group for the Operations
module "mod_ops_resource_group" {
  providers = { azurerm = azurerm.ops }
  depends_on = [
    module.mod_logging_resource_group
  ]
  source = "../../../../../terraform/core/modules/Microsoft.Resources/resourceGroups"

  //Global Settings
  location = var.location

  // Resource Group Parameters
  name = var.ops_resource_group_name

  // Resource Group Locks
  enable_resource_locks = var.enable_resource_locks
  lock_level            = var.lock_level

  // Resource Group Tags
  tags = merge(var.tags, {
    DeployedBy = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}

// Resource Group for the Operations
module "mod_svcs_resource_group" {
  providers = { azurerm = azurerm.svcs }
  depends_on = [
    module.mod_logging_resource_group
  ]
  source = "../../../../../terraform/core/modules/Microsoft.Resources/resourceGroups"

  //Global Settings
  location = var.location

  // Resource Group Parameters
  name = var.svcs_resource_group_name

  // Resource Group Locks
  enable_resource_locks = var.enable_resource_locks
  lock_level            = var.lock_level

  // Resource Group Tags
  tags = merge(var.tags, {
    DeployedBy = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}

#########################################
### STAGE 1: Logging Configuration    ###
#########################################

module "mod_logging" {
  providers = { azurerm = azurerm.ops }
  depends_on = [
    module.mod_logging_resource_group
  ]
  source = "../../../../../terraform/core/overlays/hubSpoke/logging"

  // Global Settings
  location            = var.location
  resource_group_name = module.mod_logging_resource_group.name

  // Logging Settings 
  logging_log_analytics            = var.logging_log_analytics_config
  deploy_sentinel                  = var.enable_services.deploy_sentinel
  logging_log_storage_account_name = var.logging_storage_account_name
  log_analytics_workspace_name     = var.logging_log_analytics_workspace_name
  logging_storage_account          = var.logging_storage_account_config

  // Resource Group Locks
  enable_resource_locks = var.enable_resource_locks

  // Tags
  tags = var.tags # Tags to be applied to all resources
}

#######################################
### STAGE 1: Hub Configuration      ###
#######################################

module "mod_hub_network" {
  providers = { azurerm = azurerm.hub }
  depends_on = [
    module.mod_hub_resource_group
  ]
  source = "../../../../../terraform/core/overlays/hubSpoke/hub"

  // Global Settings
  location            = var.location
  resource_group_name = module.mod_hub_resource_group.name

  // Hub Virutal Network Parameters  
  hub_virtual_network_name = var.hub_virtual_network_name
  hub_vnet_address_space   = var.hub_vnet_address_space

  // Hub Subnets
  hub_subnets = var.hub_subnets

  // Hub Network Security Group
  hub_network_security_group_name  = var.hub_network_security_group_name
  hub_network_security_group_rules = var.hub_network_security_group_rules

  // Hub Route Table
  hub_route_table_name = var.hub_route_table_name

  // Firewall Settings
  enable_firewall                              = var.enable_firewall
  firewall_name                                = var.firewall_name
  firewall_sku                                 = var.firewall_sku_name
  firewall_sku_tier                            = var.firewall_sku_tier
  firewall_policy_name                         = var.firewall_policy_name
  firewall_client_subnet_address_prefix        = var.firewall_client_subnet_address_prefix
  firewall_client_subnet_service_endpoints     = var.firewall_client_subnet_service_endpoints
  firewall_client_public_ip_address_name       = var.firewall_client_public_ip_address_name
  firewall_management_public_ip_address_name   = var.firewall_management_public_ip_address_name
  firewall_management_subnet_address_prefix    = var.firewall_management_subnet_address_prefix
  firewall_management_subnet_service_endpoints = var.firewall_management_subnet_service_endpoints
  firewall_threat_intel_mode                   = var.firewall_threat_intel_mode
  firewall_threat_detection_mode               = var.firewall_threat_detection_mode
  firewall_supernet_IP_address                 = var.firewall_supernet_IP_address

  // Firewall Rules
  enable_forced_tunneling                     = var.enable_forced_tunneling
  firewall_policy_network_rule_collection     = var.firewall_policy_network_rule_collection
  firewall_policy_application_rule_collection = var.firewall_policy_application_rule_collection

  // Loggging Settings
  hub_log_storage_account_name       = var.hub_log_storage_account_name
  hub_logging_storage_account_config = var.hub_logging_storage_account_config

  // Locks
  enable_resource_locks = var.enable_resource_locks
  lock_level            = var.lock_level

  // Tags
  tags = var.tags # Tags to be applied to all resources

}

######################################
### STAGE 1.1: Network Artifacts   ###
######################################

############################################################################
### This stage is optional based on the value of `enable_network_artifacts`
############################################################################

/* module "mod_network_artifacts" {
  depends_on = [
    module.mod_hub_network
  ]
  source = "../../../../../terraform/core/overlays/hubSpoke/hub/networkArtifacts"

  // Global Settings
  location            = var.location
  resource_group_name = module.mod_hub_resource_group.name

  // Network Artifacts
  enable_network_artifacts = var.enable_network_artifacts
  network_artifacts = var.network_artifacts

  // Locks
  enable_resource_locks = var.enable_resource_locks
  lock_level            = var.lock_level

  // Tags
  tags = var.tags # Tags to be applied to all resources
} */

########################################
### STAGE 2: Spoke Configuration     ###
########################################

// Resources for the Operations Spoke
module "mod_ops_network" {
  providers = { azurerm = azurerm.ops }
  source    = "../../../../../terraform/core/overlays/hubSpoke/spoke"

  // Global Settings
  location            = var.location
  resource_group_name = module.mod_ops_resource_group.name

  // Firewall
  firewall_private_ip_address = module.mod_hub_network.private_ip

  // Operations Spoke Configuration
  spoke_vnetname           = var.ops_virtual_network_name
  spoke_vnet_address_space = var.ops_spoke_vnet_address_space

  // Operations Spoke Subnets
  spoke_subnets                      = var.ops_spoke_subnets
  spoke_network_security_group_name  = var.ops_network_security_group_name
  spoke_network_security_group_rules = var.ops_network_security_group_rules
  spoke_route_table_name             = var.ops_route_table_name

  // Loggging Settings
  spoke_log_storage_account_name       = var.ops_log_storage_account_name
  spoke_logging_storage_account_config = var.ops_logging_storage_account_config

  // Locks
  enable_resource_locks = var.enable_resource_locks
  lock_level            = var.lock_level

  // Tags
  tags = var.tags
}

// Resources for the Shared Services Spoke
module "mod_svcs_network" {
  providers = { azurerm = azurerm.svcs }
  source    = "../../../../../terraform/core/overlays/hubSpoke/spoke"

  // Global Settings
  location            = var.location
  resource_group_name = module.mod_svcs_resource_group.name

  // Firewall
  firewall_private_ip_address = module.mod_hub_network.private_ip

  // Shared Services Spoke Configuration
  spoke_vnetname           = var.svcs_virtual_network_name
  spoke_vnet_address_space = var.svcs_spoke_vnet_address_space

  // Shared Services Spoke Subnets
  spoke_subnets                      = var.svcs_spoke_subnets
  spoke_network_security_group_name  = var.svcs_network_security_group_name
  spoke_network_security_group_rules = var.svcs_network_security_group_rules
  spoke_route_table_name             = var.svcs_route_table_name

  // Loggging Settings
  spoke_log_storage_account_name       = var.svcs_log_storage_account_name
  spoke_logging_storage_account_config = var.svcs_logging_storage_account_config

  // Locks
  enable_resource_locks = var.enable_resource_locks
  lock_level            = var.lock_level

  // Tags
  tags = var.tags
}

####################################
## STAGE 3: Networking Peering   ###
####################################

module "mod_hub_to_ops_networking_peering" {
  depends_on = [
    module.mod_hub_network,
    module.mod_ops_network
  ]
  source = "../../../../../terraform/core/overlays/hubSpoke/peering"

  count = var.peer_to_hub_virtual_network ? 1 : 0

  // Hub Networking Peering Settings
  peering_name_1_to_2 = "${module.mod_hub_network.virtual_network_name}-to-${module.mod_ops_network.virtual_network_name}"
  vnet_1_id           = module.mod_hub_network.virtual_network_id
  vnet_1_name         = module.mod_hub_network.virtual_network_name
  vnet_1_rg           = module.mod_hub_resource_group.name

  // Operations Networking Peering Settings
  peering_name_2_to_1 = "${module.mod_ops_network.virtual_network_name}-to-${module.mod_hub_network.virtual_network_name}"
  vnet_2_id           = module.mod_ops_network.virtual_network_id
  vnet_2_name         = module.mod_ops_network.virtual_network_name
  vnet_2_rg           = module.mod_ops_network.resource_group_name

  // Settings
  allow_virtual_network_access = var.allow_virtual_network_access
  use_remote_gateways          = var.use_remote_gateways
}

module "mod_hub_to_svcs_networking_peering" {
  depends_on = [
    module.mod_hub_network,
    module.mod_svcs_network
  ]
  source = "../../../../../terraform/core/overlays/hubSpoke/peering"

  count = var.peer_to_hub_virtual_network ? 1 : 0

  // Hub Networking Peering Settings
  peering_name_1_to_2 = "${module.mod_hub_network.virtual_network_name}-to-${module.mod_svcs_network.virtual_network_name}"
  vnet_1_id           = module.mod_hub_network.virtual_network_id
  vnet_1_name         = module.mod_hub_network.virtual_network_name
  vnet_1_rg           = module.mod_hub_resource_group.name

  // Shared Services Networking Peering Settings
  peering_name_2_to_1 = "${module.mod_svcs_network.virtual_network_name}-to-${module.mod_hub_network.virtual_network_name}"
  vnet_2_id           = module.mod_svcs_network.virtual_network_id
  vnet_2_name         = module.mod_svcs_network.virtual_network_name
  vnet_2_rg           = module.mod_svcs_network.resource_group_name

  // Settings
  allow_virtual_network_access = var.allow_virtual_network_access
  use_remote_gateways          = var.use_remote_gateways
}

########################################
### STAGE 4: Azure Security Center   ###
########################################

module "mod_azure_security_center" {
  providers  = { azurerm = azurerm.hub }
  depends_on = [module.mod_hub_network]
  source     = "../../../../../terraform/core/modules/Microsoft.Security/azureSecurityCenter"

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
### STAGE 5: Remote Access   ###
################################

#########################################################################
### This stage is optional based on the value of `create_bastion_host`
#########################################################################

module "mod_bastion_host" {
  providers  = { azurerm = azurerm.hub }
  depends_on = [module.mod_hub_network]
  source     = "../../../../../terraform/core/overlays/bastion"

  // Global Settings
  org_prefix          = var.required.org_prefix
  resource_group_name = module.mod_hub_resource_group.name
  location            = var.location

  // Bastion Host Settings
  virtual_network_name             = module.mod_hub_network.virtual_network_name
  subnet_name                      = "hub-snet"
  network_security_group_name      = var.hub_network_security_group_name
  bastion_address_space            = var.bastion_address_space
  bastion_subnet_service_endpoints = var.bastion_subnet_service_endpoints

  // Bastions Diagnostics Settings
  enable_bastion_diagnostics       = var.enable_services.enable_bastion_diagnostics
  log_analytics_storage_account_id = module.mod_logging.laws_StorageAccount_Id

  // Jumpbox Settings
  admin_username              = var.jumpbox_admin_username # The admin username for the jumpbox
  use_random_password         = var.use_random_password    # If true, a random password will be generated and stored in the Azure Key Vault
  log_analytics_workspace_id  = module.mod_logging.laws_resource_id
  log_analytics_workspace_key = module.mod_logging.laws_workspace_key

  // Linux Jumpbox Settings
  create_bastion_linux_jumpbox = var.enable_services.bastion_linux_virtual_machines # If true, a Linux jumpbox will be created
  vm_os_linux_disk_image       = var.jumpbox_linux_os_disk_image
  size_linux_jumpbox           = var.size_linux_jumpbox

  // Windows Jumpbox Settings
  create_bastion_windows_jumpbox = var.enable_services.bastion_windows_virtual_machines # If true, a Windows jumpbox will be created
  vm_os_windows_disk_image       = var.jumpbox_windows_os_disk_image
  size_windows_jumpbox           = var.size_windows_jumpbox

  // Tags
  tags = var.tags # Tags to be applied to all resources
}

