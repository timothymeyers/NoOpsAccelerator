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
*/

#########################################
### STAGE 4: Hub/Spoke Configuations  ###
#########################################

################################
### STAGE 4.1: Scaffolding   ###
################################

// Resource Group for the Logging
resource "azurerm_resource_group" "operational_logging_resource_group" {
  name     = lower(local.loggingResourceGroupName)
  location = local.location
  tags     = merge({ "ResourceName" = format("%s", local.loggingResourceGroupName), DeployedBy = format("AzureNoOpsTF [%s]", terraform.workspace) }, var.tags, )
}

###########################################
### STAGE 4.1: Logging Configuration    ###
###########################################

module "mod_operational_logging" {
  providers = { azurerm = azurerm.ops }
  depends_on = [
    azurerm_resource_group.operational_logging_resource_group
  ]
  source = "../../../terraform/core/overlays/hubSpoke/operationalLogging"

  // Global Settings
  location            = local.location
  resource_group_name = azurerm_resource_group.operational_logging_resource_group.name

  // Logging Settings 
  logging_log_analytics        = var.log_analytics_config
  deploy_sentinel              = var.enable_services.deploy_sentinel
  storage_account_name         = local.loggingLogStorageAccountName
  log_analytics_workspace_name = local.logAnalyticsWorkspaceName

  // Resource Group Locks
  enable_resource_locks = var.enable_services.enable_resource_locks

  // Tags
  tags = var.tags # Tags to be applied to all resources
}

#######################################
### STAGE 4.2: Hub Configuration    ###
#######################################

module "mod_hub_network" {
  providers = { azurerm = azurerm.hub }
  source    = "../../../terraform/core/overlays/hubSpoke/virtualNetworkHub"

  // Global Settings
  location            = local.location
  resource_group_name = local.hubResourceGroupName

  # By default, this module should not create a resource group, but if you want to create a resource group, set this to true
  create_hub_resource_group = true

  // Hub Virutal Network Parameters  
  virtual_network_name          = local.hubVirtualNetworkName
  virtual_network_address_space = var.hub_vnet_address_space

  // Hub Subnets
  subnet_name                                = local.hubSubnetName
  subnet_address_prefixes                    = var.hub_vnet_subnet_address_prefixes
  subnet_service_endpoints                   = var.hub_vnet_subnet_service_endpoints
  private_endpoint_network_policies_enabled  = false
  private_endpoint_service_endpoints_enabled = true

  // Hub Network Security Group
  network_security_group_name  = local.hubNetworkSecurityGroupName
  network_security_group_inbound_rules = var.hub_network_security_group_inbound_rules
  network_security_group_outbound_rules = var.hub_network_security_group_outbound_rules

  // Hub Route Table
  route_table_name = local.hubRouteTableName

  // Firewall Settings
  create_firewall                           = var.enable_services.enable_firewall
  enable_forced_tunneling                   = var.enable_services.enable_forced_tunneling
  firewall_subnet_address_prefix            = var.firewall_client_subnet_address_prefix
  firewall_client_publicIP_address_name     = local.firewallClientPublicIPAddressName
  firewall_management_subnet_address_prefix = var.firewall_management_subnet_address_prefix
  firewall_management_publicIP_address_name = local.firewallManagementPublicIPAddressName

  # Firewall Config
  firewall_config = {
    name              = local.firewallName
    sku_name          = var.firewall_sku_name
    sku_tier          = var.firewall_sku_tier
    threat_intel_mode = var.firewall_threat_intel_mode
  }


  // Firewall Rules  
  firewall_network_rules     = var.firewall_policy_network_rule_collection
  firewall_application_rules = var.firewall_policy_application_rule_collection

  // Loggging Settings
  storage_account_name = local.hubLogStorageAccountName

  // Locks
  enable_resource_locks = var.enable_services.enable_resource_locks
  lock_level            = var.lock_level

  // Tags
  tags = var.tags # Tags to be applied to all resources

}

######################################
### STAGE 4.3: Network Artifacts   ###
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
  location            = local.location
  resource_group_name = module.mod_hub_resource_group.name

  // Network Artifacts
  enable_network_artifacts = var.enable_network_artifacts
  network_artifacts = var.network_artifacts

  // Locks
  enable_resource_locks = var.enable_services.enable_resource_locks
  lock_level            = var.lock_level

  // Tags
  tags = var.tags # Tags to be applied to all resources
} */

########################################
### STAGE 4.4: Spoke Configuration   ###
########################################

// Resources for the Operations Spoke
module "mod_ops_network" {
  providers = { azurerm = azurerm.ops }
  source    = "../../../terraform/core/overlays/hubSpoke/virtualNetworkSpoke"

  # Global Settings
  location            = local.location
  resource_group_name = local.opsResourceGroupName

  # By default, this module should not create a resource group, but if you want to create a resource group, set this to true
  create_spoke_resource_group = true

  # Operations Spoke Configuration
  virtual_network_name          = local.opsVirtualNetworkName
  virtual_network_address_space = var.ops_vnet_address_space

  # Operations Spoke Subnets
  subnet_name                                = local.opsSubnetName
  subnet_address_prefixes                    = var.ops_vnet_subnet_address_prefixes
  subnet_service_endpoints                   = var.ops_vnet_subnet_service_endpoints
  private_endpoint_network_policies_enabled  = false
  private_endpoint_service_endpoints_enabled = true

  # Operations Spoke Network Security Group
  network_security_group_name  = local.opsNetworkSecurityGroupName
  network_security_group_inbound_rules = var.ops_network_security_group_inbound_rules
  network_security_group_outbound_rules = var.ops_network_security_group_outbound_rules

  // Operations Spoke Route Table
  route_table_name = local.opsRouteTableName
  route_table_routes = {
    "default_ops_route" = {
      name                   = "RouteToAzureFirewall"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = module.mod_hub_network.firewall_private_ip
    }
  }


  // Loggging Settings
  storage_account_name = local.opsLogStorageAccountName

  // Locks
  enable_resource_locks = var.enable_services.enable_resource_locks
  lock_level            = var.lock_level

  // Tags
  tags = var.tags
}

// Resources for the Shared Services Spoke
module "mod_svcs_network" {
  providers = { azurerm = azurerm.svcs }
  source    = "../../../terraform/core/overlays/hubSpoke/virtualNetworkSpoke"

  # Global Settings
  location            = local.location
  resource_group_name = local.svcsResourceGroupName

  # By default, this module should not create a resource group, but if you want to create a resource group, set this to true
  create_spoke_resource_group = true

  # Operations Spoke Configuration
  virtual_network_name          = local.svcsVirtualNetworkName
  virtual_network_address_space = var.svcs_vnet_address_space

  # Operations Spoke Subnets
  subnet_name                                = local.svcsSubnetName
  subnet_address_prefixes                    = var.svcs_vnet_subnet_address_prefixes
  subnet_service_endpoints                   = var.svcs_vnet_subnet_service_endpoints
  private_endpoint_network_policies_enabled  = false
  private_endpoint_service_endpoints_enabled = true

  # Operations Spoke Network Security Group
  network_security_group_name  = local.svcsNetworkSecurityGroupName
  network_security_group_inbound_rules = var.svcs_network_security_group_inbound_rules
  network_security_group_outbound_rules = var.svcs_network_security_group_outbound_rules

  // Operations Spoke Route Table
  route_table_name = local.svcsRouteTableName
  route_table_routes = {
    "default_svcs_route" = {
      name                   = "RouteToAzureFirewall"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = module.mod_hub_network.firewall_private_ip
    }
  }


  // Loggging Settings
  storage_account_name = local.svcsLogStorageAccountName

  // Locks
  enable_resource_locks = var.enable_services.enable_resource_locks
  lock_level            = var.lock_level

  // Tags
  tags = var.tags
}

######################################
## STAGE 4.5: Networking Peering   ###
######################################

module "mod_hub_to_ops_networking_peering" {
  depends_on = [
    module.mod_hub_network,
    module.mod_ops_network
  ]
  source = "../../../terraform/core/overlays/hubSpoke/virtualNetworkPeering"

  count = var.peer_to_hub_virtual_network ? 1 : 0

  // Hub Networking Peering Settings
  peering_name_1_to_2 = "${module.mod_hub_network.virtual_network_name}-to-${module.mod_ops_network.virtual_network_name}"
  vnet_1_id           = module.mod_hub_network.virtual_network_id
  vnet_1_name         = module.mod_hub_network.virtual_network_name
  vnet_1_rg           = module.mod_hub_network.resource_group_name

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
  source = "../../../terraform/core/overlays/hubSpoke/virtualNetworkPeering"

  count = var.peer_to_hub_virtual_network ? 1 : 0

  // Hub Networking Peering Settings
  peering_name_1_to_2 = "${module.mod_hub_network.virtual_network_name}-to-${module.mod_svcs_network.virtual_network_name}"
  vnet_1_id           = module.mod_hub_network.virtual_network_id
  vnet_1_name         = module.mod_hub_network.virtual_network_name
  vnet_1_rg           = module.mod_hub_network.resource_group_name

  // Shared Services Networking Peering Settings
  peering_name_2_to_1 = "${module.mod_svcs_network.virtual_network_name}-to-${module.mod_hub_network.virtual_network_name}"
  vnet_2_id           = module.mod_svcs_network.virtual_network_id
  vnet_2_name         = module.mod_svcs_network.virtual_network_name
  vnet_2_rg           = module.mod_svcs_network.resource_group_name

  // Settings
  allow_virtual_network_access = var.allow_virtual_network_access
  use_remote_gateways          = var.use_remote_gateways
}

##########################################
### STAGE 4.6: Azure Security Center   ###
##########################################

module "mod_azure_security_center" {
  providers  = { azurerm = azurerm.hub }
  depends_on = [module.mod_hub_network]
  source     = "../../../terraform/core/modules/Microsoft.Security/azureSecurityCenter"

  count = var.enable_services.enable_azure_security_center ? 1 : 0

  # Logging Resource Group, location, log analytics details
  resource_group_name          = azurerm_resource_group.operational_logging_resource_group.name
  log_analytics_workspace_name = module.mod_operational_logging.laws_name
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
### This stage is optional based on the value of `enable_bastion_hosts`
#########################################################################

module "mod_bastion_host" {
  providers  = { azurerm = azurerm.hub }
  depends_on = [module.mod_hub_network]
  source     = "../../../terraform/core/overlays/bastion"

  count = var.enable_services.enable_bastion_hosts ? 1 : 0

  // Global Settings
  org_prefix          = var.required.org_prefix
  resource_group_name = module.mod_hub_network.resource_group_name
  location            = local.location

  // Bastion Host Settings
  virtual_network_name             = module.mod_hub_network.virtual_network_name
  bastion_address_space            = var.bastion_address_space
  bastion_subnet_service_endpoints = var.bastion_subnet_service_endpoints

  // Bastions Diagnostics Settings
  enable_bastion_diagnostics       = var.enable_services.enable_bastion_diagnostics
  log_analytics_storage_account_id = module.mod_operational_logging.laws_StorageAccount_Id

  // Jumpbox Settings
  vm_subnet_id                = module.mod_hub_network.default_subnet_id # The subnet ID for the jumpbox
  admin_username              = var.jumpbox_admin_username               # The admin username for the jumpbox
  use_random_password         = var.use_random_password                  # If true, a random password will be generated and stored in the Azure Key Vault
  log_analytics_workspace_id  = module.mod_operational_logging.laws_resource_id
  log_analytics_workspace_key = module.mod_operational_logging.laws_workspace_key

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

