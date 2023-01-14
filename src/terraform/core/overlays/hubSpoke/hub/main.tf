# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module to deploy the Hub Network and it's components based on the Azure Mission Landing Zone conceptual architecture
DESCRIPTION: The following components will be options in this deployment
              Hub Virtual Network (Vnet)
              Firewall
              Subnets
              Route Table
              Network Security Group
              Log Storage
              Private Link
              Private DNS Zones - Details of all the Azure Private DNS zones can be found here --> https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration
              DDos Standard Plan (optional)
PREREQS: Logging
AUTHOR/S: jspinella
*/

##############################################
### DATA ###
##############################################

data "azurerm_client_config" "current" {}

##########################################
### STAGE 1: Build out Hub Networking  ###
##########################################

#
#
# Virtual network
#
#
module "mod_hub_network" {
  source = "./virtualNetwork"

  // Global Settings
  location = var.location

  // VNET Parameters
  vnet_name           = var.hub_virtual_network_name
  vnet_address_space  = var.hub_vnet_address_space
  resource_group_name = var.resource_group_name

  // VNET Resource Lock Parameters
  enable_resource_locks = var.enable_resource_locks
  lock_level            = var.lock_level

  // Logging
  log_storage_account_name       = var.hub_log_storage_account_name
  logging_storage_account_config = var.hub_logging_storage_account_config

  // VNET Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Hub Network Resource: %s", var.hub_virtual_network_name)
  }) # Tags to be applied to all resources
}

#
#
# Subnets
#
#
module "mod_hub_subnet" {
  depends_on = [
    module.mod_hub_network,
    module.mod_networking_hub_firewall
  ]
  source = "./subnet"

  // Global Settings
  location             = var.location
  resource_group_name  = var.resource_group_name
  virtual_network_name = module.mod_hub_network.virtual_network_name

  // Subnet Parameters
  subnets = var.hub_subnets

  // Network Security Group Parameters
  network_security_group_name  = var.hub_network_security_group_name
  network_security_group_rules = var.hub_network_security_group_rules

  // Hub Route Table Name
  routetable_name = var.hub_route_table_name

  // Hub Route Table Routes
  route_table_routes = [
    {
      name                   = "RouteToAzureFirewall"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = module.mod_networking_hub_firewall.private_ip
    }
  ]

  // Tags
  tags = var.tags
}

##############################################
## STAGE 2: Hub Networking - Firewall      ###
##############################################

module "mod_networking_hub_firewall" {
  depends_on = [
    module.mod_hub_network
  ]

  source = "./firewall"

  // Global Settings
  location             = var.location
  resource_group_name  = var.resource_group_name
  virtual_network_name = module.mod_hub_network.virtual_network_name

  // Firewall Settings
  enable_firewall                              = var.enable_firewall
  firewall_name                                = var.firewall_name
  firewall_sku_name                            = var.firewall_sku
  firewall_sku_tier                            = var.firewall_sku_tier
  firewall_client_public_ip_address_name       = var.firewall_client_public_ip_address_name
  firewall_client_subnet_address_prefix        = var.firewall_client_subnet_address_prefix
  firewall_client_subnet_service_endpoints     = var.firewall_client_subnet_service_endpoints
  firewall_management_public_ip_address_name   = var.firewall_management_public_ip_address_name
  firewall_management_subnet_address_prefix    = var.firewall_management_subnet_address_prefix
  firewall_management_subnet_service_endpoints = var.firewall_management_subnet_service_endpoints
  firewall_supernet_IP_address                 = var.firewall_supernet_IP_address

  firewall_policy_name                 = var.firewall_policy_name
  firewall_threat_intel_mode           = var.firewall_threat_intel_mode
  firewall_application_rule_collection = var.firewall_policy_application_rule_collection
  firewall_network_rule_collection     = var.firewall_policy_network_rule_collection

  // Firewall Policy Settings
  enable_forced_tunneling = var.enable_forced_tunneling # Enable Forced Tunneling

  // Firewall Resource Locks
  enable_resource_locks = var.enable_resource_locks

  // Tags
  tags = var.tags # Tags to be applied to all resources # Tags to be applied to all resources
}

#################################################
### STAGE 3: Build out Hub Private DNS Zones  ###
#################################################

#
#
# Private DNS Zone
#
#
module "mod_hub_dns" {
  depends_on = [module.mod_hub_subnet]
  source     = "./privateDnsZones"

  // Private DNS Zone Parameters
  resource_group_name             = var.resource_group_name
  virtual_network_name            = module.mod_hub_network.virtual_network_name
  virtual_network_subscription_id = data.azurerm_client_config.current.subscription_id

  // Private DNS Zone Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Hub Network Resource: %s", "Private DNS Zone")
  }) # Tags to be applied to all resources

}
