# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module to deploy the Spoke Network and it's components based on the Azure Mission Landing Zone conceptual architecture
DESCRIPTION: The following components will be options in this deployment
              Spoke Virtual Network (Vnet)
              Subnets
              Route Table
              Network Security Group
              Log Storage
              Activity Logging
              Private DNS Zones - Details of all the Azure Private DNS zones can be found here --> https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration
AUTHOR/S: jspinella
*/

###################################################
### STAGE 1: Build out workload spoke network   ###
###################################################
module "mod_spoke_network" {
  source     = "./virtualNetwork"

  location            = var.location
  resource_group_name = var.resource_group_name
  vnet_name           = var.spoke_vnetname
  vnet_address_space  = var.spoke_vnet_address_space

  // Logging
  log_storage_account_name       = var.spoke_log_storage_account_name
  logging_storage_account_config = var.spoke_logging_storage_account_config

  // Resource Locks
  enable_resource_locks = var.enable_resource_locks
  lock_level            = var.lock_level

  tags = var.tags
}

module "mod_spoke_subnets" {
  depends_on = [
    module.mod_spoke_network
  ]
  source = "./subnet"

  location                     = var.location
  resource_group_name          = var.resource_group_name
  virtual_network_name         = module.mod_spoke_network.virtual_network_name
  spoke_subnets                = var.spoke_subnets
  network_security_group_name  = var.spoke_network_security_group_name
  network_security_group_rules = var.spoke_network_security_group_rules

  routetable_name             = var.spoke_route_table_name
  firewall_private_ip_address = var.firewall_private_ip_address

  // Resource Locks
  enable_resource_locks = var.enable_resource_locks
  lock_level            = var.lock_level


  tags = var.tags
}
