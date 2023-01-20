# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Create a virtual network with subnets, NSG, DDoS protection plan, and network watcher resources.

#---------------------------------------------------------
# Resource Group Creation or selection - Default is "false"
#----------------------------------------------------------
data "azurerm_resource_group" "rgrp" {
  count = var.create_spoke_resource_group == false ? 1 : 0
  name  = var.resource_group_name
}

# By default, this module will not create a resource group, provide the name here
# to use an existing resource group, specify the existing resource group name,
# and set the argument to `create_resource_group = true`. Location will be same as existing RG.
resource "azurerm_resource_group" "rg" {
  count    = var.create_spoke_resource_group ? 1 : 0
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

#-----------------------------------------------
# Storage Account for Logs Archive
#-----------------------------------------------
module "mod_storage_account" {
  source = "../../storageAccount"

  //Global Settings
  create_storage_account_resource_group = false
  resource_group_name = local.resource_group_name
  location            = local.location

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
    description = format("Spoke Logging Resource: %s", var.storage_account_name)
  }) # Tags to be applied to all resources
}

