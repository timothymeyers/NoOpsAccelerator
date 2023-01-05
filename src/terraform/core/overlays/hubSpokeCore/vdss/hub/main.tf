# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module to deploy the Hub Network and it's components based on the Azure Mission Landing Zone conceptual architecture
DESCRIPTION: The following components will be options in this deployment
              Hub Virtual Network (Vnet)
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

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

##############################################
### DATA ###
##############################################

data "azurerm_client_config" "current" {}

##############################################
### STAGE 1: Build out hub storage account ###
##############################################

module "mod_hub_logging_storage" {
  source = "../../../../modules/Microsoft.Storage"

  //Global Settings
  location = var.location

  // Storage Account Parameters
  name                = var.hub_log_storage_account_name
  resource_group_name = var.resource_group_name
  storage_account     = var.hub_logging_storage_account
}

output "storage_accounts" {
  value     = module.mod_hub_logging_storage
  sensitive = true
}

##########################################
### STAGE 2: Build out Hub Networking  ###
##########################################

#
#
# Virtual network
#
#
module "mod_hub_network" {
  depends_on = [module.mod_hub_logging_storage]
  source     = "../../../../modules/Microsoft.Network/virtualNetworks"

  // Global Settings
  location = var.location

  // VNET Parameters
  vnet_name           = var.hub_virtual_network_name
  vnet_address_space  = var.hub_vnet_address_space
  resource_group_name = var.resource_group_name

  // VNET Resource Lock Parameters
  enable_resource_lock = var.enable_resource_locks
  lock_level           = "CanNotDelete"

  // VNET Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Hub Network Resource: %s", var.hub_virtual_network_name)
  }) # Tags to be applied to all resources
}

#
#
# Route Table
#
#
module "hub_routetable" {
  source = "../../../../modules/Microsoft.Network/routeTables"

  // Global Settings
  location = var.location

  // Route Table Parameters
  name                          = var.hub_route_table_name
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = true

  // Routetable Resource Lock Parameters
  enable_resource_lock = var.enable_resource_locks
  lock_level           = "CanNotDelete"

  // Routetable Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Hub Network Resource: %s", var.hub_route_table_name)
  }) # Tags to be applied to all resources


}

#
#
# Route Table
#
#
module "hub_default_route" {
  source = "../../../../modules/Microsoft.Network/routeTables/route"

  // Route Table Route Parameters
  name                   = "default_route"
  resource_group_name    = var.resource_group_name
  location               = var.location
  routetable_name        = module.hub_routetable.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.firewall_private_ip
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [
    module.hub_default_route
  ]

  create_duration = "30s"
}

#
#
# Route Table to Subnet Association
#
#
resource "azurerm_subnet_route_table_association" "routetable" {
  depends_on = [
    module.hub_default_route,
    time_sleep.wait_30_seconds
  ]

  subnet_id      = module.mod_hub_subnet.subnet_ids[var.hub_subnet_name]
  route_table_id = module.hub_routetable.id
}

#
#
# Hub Subnet
#
#
module "mod_hub_subnet" {
  depends_on = [module.mod_hub_network]
  source     = "../../../../modules/Microsoft.Network/subnets"

  // Global Settings
  location = var.location

  // Subnet Parameters
  resource_group_name  = var.resource_group_name
  virtual_network_name = module.mod_hub_network.virtual_network_name

  subnets = [
    {
      name : var.hub_subnet_name
      address_prefixes : [cidrsubnet(var.hub_vnet_subnet_address_space, 0, 0)]
      service_endpoints : var.hub_subnet_service_endpoints
      enforce_private_link_endpoint_network_policies : false
      enforce_private_link_service_network_policies : false
    }
  ]

  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Hub Network Resource: %s", var.hub_subnet_name)
  }) # Tags to be applied to all resources
}

#
#
# Network Security Group
#
#
module "mod_hub_network_nsg" {
  depends_on = [module.mod_hub_subnet]
  source     = "../../../../modules/Microsoft.Network/networkSecurityGroups"

  // Global Settings
  location = var.location

  // NSG Parameters
  name                = var.hub_network_security_group_name
  resource_group_name = var.resource_group_name

  // NSG Resource Lock Parameters
  enable_resource_lock = var.enable_resource_locks
  lock_level           = "CanNotDelete"

  // NSG Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Hub Network Resource: %s", var.hub_network_security_group_name)
  }) # Tags to be applied to all resources
}

# Associate the NSG with the subnet
resource "azurerm_subnet_network_security_group_association" "nsg" {
  subnet_id                 = module.mod_hub_subnet.subnet_ids[var.hub_subnet_name]
  network_security_group_id = module.mod_hub_network_nsg.id
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
  depends_on = [module.mod_hub_network_nsg]
  source     = "../privateDnsZones"

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
