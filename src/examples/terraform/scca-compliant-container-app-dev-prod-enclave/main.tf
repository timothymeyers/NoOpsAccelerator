# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module Example to deploy an SCCA Compliant Hub/ 1 Spoke Mission Enclave with Azure Kubernetes Service (AKS) and Azure Firewall
DESCRIPTION: The following components will be options in this deployment
            * Mission Enclave - Management Groups and Subscriptions
              * Management Group
                * Org
                * Team
              * Subscription
                * Hub
                * Operations
            * Mission Enclave - Azure Policy via code
              * Azure Policy Initiative
                * Monitoring
                  * Deploy Diagnostic Settings
                * General
                * Network
                * Compute
              * Azure Policy Assignment
            * Mission Enclave - Roles
              * Azure Role Definations
              * Azure Role Assignment
                * Contributor
                * Virtual Machine Contributor
            * Mission Enclave - Hub/Spoke
              * Hub Virtual Network (VNet)
              * Identity Network Artifacts
              * Operations Network Artifacts
              * Shared Services Network Artifacts
              * Bastion Host (Optional)
              * DDos Standard Plan (Optional)
              * Microsoft Defender for Cloud (Optional)
              * Automation Account (Optional)
              * Spokes
                * Identity (Tier 0)
                * Operations (Tier 1)
                * Shared Services (Tier 2)
              * Logging via Operations (Tier 1)
                * Azure Sentinel
                * Azure Log Analytics
                * Azure Log Analytics Solutions
              * Azure Firewall
              * Private DNS Zones - Details of all the Azure Private DNS zones can be found here --> [https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration](https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration)
            * Mission Enclave - Workloads
              * Azure Kubernetes Service (AKS)              
AUTHOR/S: jspinella
*/

##################
### DATA       ###
##################
# Azure Provider
data "azurerm_subscription" "primary" {}
data "azurerm_client_config" "current_client" {}

# Contributor role
data "azurerm_role_definition" "contributor" {
  name = "Contributor"
}

# Virtual Machine Contributor role
data "azurerm_role_definition" "vm_contributor" {
  name = "Virtual Machine Contributor"
}

################################################
### STAGE 0: Management Group Configuations  ###
################################################

module "mod_management_group" {
  source            = "../../../terraform/core/overlays/managementGroups"
  root_id           = var.root_management_group_id
  root_display_name = var.root_management_group_display_name
  management_groups = var.management_groups
}

#####################################
### STAGE 1: Roles Configuations  ###
#####################################

module "roles" {
  source              = "../../../terraform/core/overlays/customRoles"
  deploy_custom_roles = var.enable_services.deploy_custom_roles
  custom_role_definitions = [
    {
      role_definition_name = "Custom - Network Operations (NetOps)"
      description          = "Platform-wide global connectivity management: virtual networks, UDRs, NSGs, NVAs, VPN, Azure ExpressRoute, and others."
      permissions = {
        actions = [
          "Microsoft.Network/virtualNetworks/read",
          "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/read",
          "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/write",
          "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/delete",
          "Microsoft.Network/virtualNetworks/peer/action",
          "Microsoft.Resources/deployments/operationStatuses/read",
          "Microsoft.Resources/deployments/write",
          "Microsoft.Resources/deployments/read"
        ]
        data_actions     = []
        not_actions      = []
        not_data_actions = []
      }
    }
  ]
}

#################################################
### STAGE 2: Policy Definitions Configuations ###
#################################################

##################
# General
##################
module "deny_resources_types" {
  depends_on = [
    module.mod_management_group
  ]
  source          = "../../../terraform/core/modules/Microsoft.Authorization/policyDefinition"
  file_path       = "../../../policyascode/definitions/custom/general/deny_resources_types.json"
  policy_name     = "deny_resources_types"
  display_name    = "Deny Azure Resource types"
  policy_category = "General"
  //management_group_id = module.management_group.management_groups[var.root_management_group_id].id
}

module "allow_regions" {
  depends_on = [
    module.mod_management_group
  ]
  source          = "../../../terraform/core/modules/Microsoft.Authorization/policyDefinition"
  file_path       = "../../../policyascode/definitions/custom/general/allow_regions.json"
  policy_name     = "allow_regions"
  display_name    = "Allow Azure Regions"
  policy_category = "General"
}

##################
# Monitoring
##################

# create definitions by looping around all files found under the Monitoring category folder
module "deploy_resource_diagnostic_setting" {
  depends_on = [
    module.mod_management_group
  ]
  source          = "../../../terraform/core/modules/Microsoft.Authorization/policyDefinition"
  for_each        = toset([for p in fileset("../../../policyascode/definitions/custom/Monitoring", "*.json") : trimsuffix(basename(p), ".json")])
  file_path       = "../../../policyascode/definitions/custom/Monitoring/${each.key}.json"
  policy_name     = each.key
  policy_category = "Monitoring"
}

##################
# Network
##################
module "deny_nic_public_ip" {
  depends_on = [
    module.mod_management_group
  ]
  source          = "../../../terraform/core/modules/Microsoft.Authorization/policyDefinition"
  file_path       = "../../../policyascode/definitions/custom/Network/deny_nic_public_ip.json"
  policy_name     = "deny_nic_public_ip"
  display_name    = "Network interfaces should not have public IPs"
  policy_category = "Network"
}

##################
# Storage
##################
module "storage_enforce_https" {
  depends_on = [
    module.mod_management_group
  ]
  source          = "../../../terraform/core/modules/Microsoft.Authorization/policyDefinition"
  file_path       = "../../../policyascode/definitions/custom/Storage/storage_enforce_https.json"
  policy_name     = "storage_enforce_https"
  display_name    = "Secure transfer to storage accounts should be enabled"
  policy_category = "Storage"
  policy_mode     = "Indexed"
}

module "storage_enforce_minimum_tls1_2" {
  depends_on = [
    module.mod_management_group
  ]
  source          = "../../../terraform/core/modules/Microsoft.Authorization/policyDefinition"
  file_path       = "../../../policyascode/definitions/custom/Storage/storage_enforce_minimum_tls1_2.json"
  policy_name     = "storage_enforce_minimum_tls1_2"
  display_name    = "Minimum TLS version for data in transit to storage accounts should be set"
  policy_category = "Storage"
  policy_mode     = "Indexed"
}

##################
# Tags
##################

module "inherit_resource_group_tags_modify" {
  depends_on = [
    module.mod_management_group
  ]
  source          = "../../../terraform/core/modules/Microsoft.Authorization/policyDefinition"
  file_path       = "../../../policyascode/definitions/custom/Tags/inherit_resource_group_tags_modify.json"
  policy_name     = "inherit_resource_group_tags_modify"
  display_name    = "Resources should inherit Resource Group Tags and Values with Modify Remediation"
  policy_category = "Tags"
  policy_mode     = "Indexed"
}

##############################################################
### STAGE 2.1: Policy Initiative Definitions Configuations ###
##############################################################

// view the policy initiative definitions in the policy_initiative.tf file

#########################################
### STAGE 3: Hub/Spoke Configuations  ###
#########################################

module "mod_landingzone_hub2spoke" {
  source = "./support/landingZone"

  // Global Settings
  required          = var.required
  location          = var.location
  environment       = var.environment
  metadata_host     = var.metadata_host
  disable_telemetry = var.disable_telemetry

  // Enabling Services. This will enable/disable the deployment of the services
  enable_services = var.enable_services

  ##################
  # Logging     ####
  ##################

  // Logging Settings
  logging_resource_group_name          = local.loggingResourceGroupName
  logging_storage_account_name         = local.loggingLogStorageAccountName
  logging_log_analytics_workspace_name = local.logAnalyticsWorkspaceName
  logging_storage_account_config       = var.logging_storage_account_config
  logging_log_analytics_config         = var.logging_log_analytics_config

  ###########################
  # Network Artifacts    ####
  ###########################

  // Network Artifacts Settings
  enable_network_artifacts = var.enable_services.enable_network_artifacts
  //network_artifacts_storage_account = var.network_artifacts_storage_account

  ##############
  # Hub     ####
  ##############

  // Hub Networking Settings
  hub_subid                       = var.hub_subid
  hub_resource_group_name         = local.hubResourceGroupName
  hub_virtual_network_name        = local.hubVirtualNetworkName
  hub_vnet_address_space          = var.hub_vnet_address_space
  hub_subnets                     = var.hub_subnets
  hub_network_security_group_name = local.hubNetworkSecurityGroupName
  hub_route_table_name            = local.hubRouteTableName
  hub_log_storage_account_name    = local.hubLogStorageAccountName

  hub_logging_storage_account_config = var.hub_logging_storage_account_config


  #################
  # Firewall   ####
  #################

  // Hub Firewall Settings
  enable_firewall                = var.enable_services.enable_firewall
  enable_forced_tunneling        = var.enable_services.enable_forced_tunneling
  firewall_name                  = local.firewallName
  firewall_sku_tier              = var.firewall_sku_tier
  firewall_sku_name              = var.firewall_sku_name
  firewall_threat_intel_mode     = var.firewall_threat_intel_mode
  firewall_threat_detection_mode = var.firewall_threat_detection_mode
  firewall_policy_name           = local.firewallPolicyName

  firewall_client_subnet_address_prefix               = var.firewall_client_subnet_address_prefix
  firewall_client_subnet_service_endpoints            = var.firewall_client_subnet_service_endpoints
  firewall_client_publicIP_address_availability_zones = var.firewall_client_publicIP_address_availability_zones
  firewall_client_public_ip_address_name              = local.firewallClientPublicIPAddressName

  firewall_management_subnet_address_prefix               = var.firewall_management_subnet_address_prefix
  firewall_management_subnet_service_endpoints            = var.firewall_management_subnet_service_endpoints
  firewall_management_publicIP_address_availability_zones = var.firewall_management_publicIP_address_availability_zones
  firewall_management_public_ip_address_name              = local.firewallClientPublicIPAddressName

  firewall_supernet_IP_address = var.firewall_supernet_IP_address

  ################
  # Spokes    ####
  ################

  // Operations Settings
  ops_subid                          = var.ops_subid
  ops_resource_group_name            = local.opsResourceGroupName
  ops_virtual_network_name           = local.opsVirtualNetworkName
  ops_network_security_group_name    = local.opsNetworkSecurityGroupName
  ops_route_table_name               = local.opsRouteTableName
  ops_spoke_vnet_address_space       = var.ops_spoke_vnet_address_space
  ops_spoke_subnets                  = var.ops_spoke_subnets
  ops_log_storage_account_name       = local.opsLogStorageAccountName
  ops_logging_storage_account_config = var.ops_logging_storage_account_config

  // Shared Services Settings
  svcs_subid                          = var.svcs_subid
  svcs_resource_group_name            = local.svcsResourceGroupName
  svcs_virtual_network_name           = local.svcsVirtualNetworkName
  svcs_network_security_group_name    = local.svcsNetworkSecurityGroupName
  svcs_route_table_name               = local.svcsRouteTableName
  svcs_spoke_vnet_address_space       = var.svcs_spoke_vnet_address_space
  svcs_spoke_subnets                  = var.svcs_spoke_subnets
  svcs_log_storage_account_name       = local.svcsLogStorageAccountName
  svcs_logging_storage_account_config = var.svcs_logging_storage_account_config

  ##################################
  # Network Peering Configuration ##
  ##################################

  // Hub to Spokes
  peer_to_hub_virtual_network  = var.peer_to_hub_virtual_network
  allow_virtual_network_access = var.allow_virtual_network_access
  use_remote_gateways          = var.use_remote_gateways

  ##################
  # Bastion     ####
  ##################

  // Bastion Settings
  bastion_address_space            = var.bastion_address_space
  bastion_subnet_service_endpoints = var.bastion_subnet_service_endpoints

  // Jumpbox Settings
  jumpbox_admin_username = var.jumpbox_admin_username # The admin username for the jumpbox
  use_random_password    = var.use_random_password    # If true, a random password will be generated and stored in the Azure Key Vault
  size_jumpbox           = var.size_jumpbox

  // Linux Jumpbox Settings  
  jumpbox_linux_os_disk_image = var.jumpbox_linux_os_disk_image

  // Windows Jumpbox Settings
  jumpbox_windows_os_disk_image = var.jumpbox_windows_os_disk_image

  // Locks
  enable_resource_locks = var.enable_services.enable_resource_locks

  ###############
  # Tags     ####
  ###############

  // Tags
  tags = merge(var.tags, {
    DeployedBy = format("AzureNoOpsTF [%s]", terraform.workspace)
  }) # Tags to be applied to all resources
}

################################################
### STAGE 4: Policy Assignment Configuations ###
################################################

##################
# General     ####
##################


###################
# Monitoring   ####
###################


##################
# Storage     ####
##################

###############################################
### STAGE 5: Workload Network Configuations ###
###############################################

module "dev_env_spoke_network" {
  source = "./support/workloads/devEnvSpoke"

  # General Settings
  wl_resource_group_name = local.wlResourceGroupName
  location               = var.location

  # Network Settings
  wl_subid                          = var.wl_subid
  wl_virtual_network_name           = local.wlVirtualNetworkName
  wl_spoke_vnet_address_space       = var.wl_spoke_vnet_address_space
  wl_network_security_group_name    = local.wlNetworkSecurityGroupName
  wl_route_table_name               = local.wlRouteTableName
  wl_spoke_subnets                  = var.wl_spoke_subnets
  wl_log_storage_account_name       = local.wlLogStorageAccountName
  wl_logging_storage_account_config = var.wl_logging_storage_account_config

  // Network Peering Configuration
  peer_to_hub_virtual_network  = var.peer_to_hub_virtual_network
  allow_virtual_network_access = var.allow_virtual_network_access
  use_remote_gateways          = var.use_remote_gateways

  // Firewall Settings
  firewall_private_ip = module.mod_landingzone_hub2spoke.firewall_private_ip_address

  // Hub Settings
  hub_resource_group_name  = module.mod_landingzone_hub2spoke.hub_rgname
  hub_virtual_network_name = module.mod_landingzone_hub2spoke.hub_vnetname

  // Locks
  enable_resource_locks = var.enable_services.enable_resource_locks

  // Tags
  tags = merge(var.tags, {
    DeployedBy = format("AzureNoOpsTF [%s]", terraform.workspace)
  }) # Tags to be applied to all resources
}

###########################################
### STAGE 5: AKS Workload Configuations ###
###########################################

