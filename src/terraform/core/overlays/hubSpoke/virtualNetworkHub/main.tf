# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Create a virtual network with subnets, NSG, DDoS protection plan, and network watcher resources.

#---------------------------------------------------------
# Resource Group Creation or selection - Default is "false"
#----------------------------------------------------------
data "azurerm_resource_group" "rgrp" {
  count = var.create_hub_resource_group == false ? 1 : 0
  name  = var.resource_group_name
}

# By default, this module will not create a resource group, provide the name here
# to use an existing resource group, specify the existing resource group name,
# and set the argument to `create_resource_group = true`. Location will be same as existing RG.
resource "azurerm_resource_group" "rg" {
  count    = var.create_hub_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = merge({ "ResourceName" = format("%s", var.resource_group_name) }, var.tags, )
}

#---------------------------------------------------------
# Vnet Creation or selection 
#----------------------------------------------------------
module "mod_vnet" {
  source = "../../../modules/Microsoft.Network/virtualNetworks"

  resource_group_name = local.resource_group_name
  vnetwork_name       = var.virtual_network_name
  location            = local.location
  vnet_address_space  = var.virtual_network_address_space

  # Adding Network Watcher (Optional)
  create_network_watcher = var.create_network_watcher

  # Adding Standard DDoS Plan (Optional)
  create_ddos_plan = var.create_ddos_plan
  ddos_plan_name   = var.create_ddos_plan ? var.ddos_plan_name : null
}

#--------------------------------------------------------------------------------------------------------
# Subnets Creation with, private link endpoint/servie network policies, service endpoints and Deligation.
#--------------------------------------------------------------------------------------------------------

#---------------------------------------------------------
# Firewall Subnet Creation or selection
#----------------------------------------------------------
module "mod_fw_client_snet" {
  source                                        = "../../../modules/Microsoft.Network/subnets"
  subnet_name                                   = "AzureFirewallSubnet"
  resource_group_name                           = local.resource_group_name
  location                                      = local.location
  virtual_network_name                          = module.mod_vnet.virtual_network_name
  address_prefixes                              = [cidrsubnet(var.firewall_subnet_address_prefix, 0, 0)]
  service_endpoints                             = var.firewall_service_endpoints
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = false
}

#---------------------------------------------------------
# Firewall Managemnet Subnet Creation
#----------------------------------------------------------
module "mod_fw_managwment_snet" {
  source                                        = "../../../modules/Microsoft.Network/subnets"
  count                                         = (var.enable_forced_tunneling && var.firewall_management_subnet_address_prefix != null) ? 1 : 0
  subnet_name                                   = "AzureFirewallManagementSubnet"
  resource_group_name                           = local.resource_group_name
  location                                      = local.location
  virtual_network_name                          = module.mod_vnet.virtual_network_name
  address_prefixes                              = [cidrsubnet(var.firewall_management_subnet_address_prefix, 0, 0)]
  service_endpoints                             = var.firewall_service_endpoints
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = false
}

module "mod_gw_snet" {
  source                                        = "../../../modules/Microsoft.Network/subnets"
  count                                         = var.gateway_subnet_address_prefix != null ? 1 : 0
  subnet_name                                   = "GatewaySubnet"
  resource_group_name                           = local.resource_group_name
  location                                      = local.location
  virtual_network_name                          = module.mod_vnet.virtual_network_name
  address_prefixes                              = var.gateway_subnet_address_prefix #[cidrsubnet(element(var.vnet_address_space, 0), 10, 0)]
  service_endpoints                             = var.gateway_service_endpoints
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = false
}

module "mod_default_snet" {
  source                                        = "../../../modules/Microsoft.Network/subnets"
  subnet_name                                   = var.subnet_name
  resource_group_name                           = local.resource_group_name
  location                                      = local.location
  virtual_network_name                          = module.mod_vnet.virtual_network_name
  address_prefixes                              = var.subnet_address_prefixes
  service_endpoints                             = var.subnet_service_endpoints
  private_endpoint_network_policies_enabled     = var.private_endpoint_network_policies_enabled
  private_link_service_network_policies_enabled = var.private_endpoint_service_endpoints_enabled
}

#-----------------------------------------------
# Network security group - Default is "false"
#-----------------------------------------------

module "mod_nsg" {
  source              = "../../../modules/Microsoft.Network/networkSecurityGroups"
  name                = var.network_security_group_name
  resource_group_name = local.resource_group_name
  location            = local.location
  inbound_rules       = var.network_security_group_inbound_rules
  outbound_rules      = var.network_security_group_outbound_rules
}

# Associate the NSG with the subnet
resource "azurerm_subnet_network_security_group_association" "nsg" {
  depends_on = [
    module.mod_nsg,
    time_sleep.wait_30_seconds
  ]
  subnet_id                 = module.mod_default_snet.id
  network_security_group_id = module.mod_nsg.network_security_group_id
}

#-----------------------------------------------
# Route Table - Default is "false"
#-----------------------------------------------

module "mod_rt" {
  source = "../../../modules/Microsoft.Network/routeTables"

  route_table_name              = var.route_table_name
  resource_group_name           = local.resource_group_name
  location                      = local.location
  disable_bgp_route_propagation = var.disable_bgp_route_propagation
  subnets_to_associate          = var.subnets_to_associate

  // Locks
  enable_resource_locks = var.enable_resource_locks
  lock_level            = var.lock_level

  // Tags
  tags = var.tags
}

#
#
# Route Table Route Creation
#
#
module "mod_default_route" {
  source   = "../../../modules/Microsoft.Network/routeTables/route"
  for_each = { for route in var.route_table_routes : route.name => route }

  // Route Table Route Parameters
  name                   = each.value.name
  resource_group_name    = local.resource_group_name
  location               = local.location
  routetable_name        = module.mod_rt.name
  address_prefix         = each.value.address_prefix
  next_hop_type          = each.value.next_hop_type
  next_hop_in_ip_address = each.value.next_hop_in_ip_address

}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [
    module.mod_default_route
  ]

  create_duration = "30s"
}

resource "azurerm_subnet_route_table_association" "routetable_association" {
  depends_on = [
    module.mod_rt,
    time_sleep.wait_30_seconds
  ]
  subnet_id      = module.mod_default_snet.id
  route_table_id = module.mod_rt.id
}

#--------------------------------------------------------------------------------------------------------
# Firewall Creation with subnets.
#--------------------------------------------------------------------------------------------------------

module "mod_fw" {
  source              = "../../../modules/Microsoft.Network/firewalls"
  count               = var.create_firewall ? 1 : 0
  resource_group_name = local.resource_group_name
  location            = local.location

  # Azure firewall subnets
  client_subnet_id                          = module.mod_fw_client_snet.id
  firewall_client_publicIP_address_name     = var.firewall_client_publicIP_address_name
  firewall_management_publicIP_address_name = var.firewall_management_publicIP_address_name
  management_subnet_id                      = (var.enable_forced_tunneling && var.firewall_management_subnet_address_prefix != null) ? module.mod_fw_managwment_snet[0].id : null

  # 

  # Azure firewall general configuration 
  # If `virtual_hub` is specified, the threat_intel_mode has to be explicitly set as `""`
  # If `virtual_hub` is not specified, the threat_intel_mode has to be explicitly set as `"Alert"`
  # Example:
  # firewall_config = { 
  #   name              = "testfirewall1"
  #   sku_name          = "AZFW_VNet"
  #   sku_tier          = "Standard"
  #   private_ip_ranges = ["IANAPrivateRanges"]
  #   threat_intel_mode = "Alert"
  #  }
  firewall_config = var.firewall_config

  # Allow force-tunnelling of traffic to be performed by the firewall
  # The Management Subnet used for the Firewall must have the name `AzureFirewallManagementSubnet` 
  # and the subnet mask must be at least a /26.
  enable_forced_tunneling = var.enable_forced_tunneling

  # Azure firewall rules
  firewall_application_rules = var.firewall_application_rules
  firewall_nat_rules         = var.firewall_nat_rules
  firewall_network_rules     = var.firewall_network_rules
}

#-----------------------------------------------
# Storage Account for Logs Archive
#-----------------------------------------------
module "mod_storage_account" {
  source = "../../storageAccount"

  //Global Settings
  create_storage_account_resource_group = false
  resource_group_name                   = local.resource_group_name
  location                              = local.location

  // Storage Account Parameters
  storage_account_name = var.storage_account_name
  account_kind         = "StorageV2" # StorageV2 is the only supported kind for Azure Firewall
  sku_name             = "Standard_LRS"

  // Locks
  enable_resource_locks = var.enable_resource_locks
  lock_level            = var.lock_level

  // Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Hub Logging Resource: %s", var.storage_account_name)
  }) # Tags to be applied to all resources
}
