# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module to deploy the Operations Network and it's components based on the Azure Mission Landing Zone conceptual architecture
DESCRIPTION: The following components will be options in this deployment
              Operations Virtual Network (Vnet)
              Subnets
              Route Table
              Network Security Group
              Log Storage
              Activity Logging
              Private DNS Zones - Details of all the Azure Private DNS zones can be found here --> https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration
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
### STAGE 1: Build out ops storage account ###
##############################################

module "mod_ops_logging_storage" {
  source = "../../../../modules/Microsoft.Storage"

  //Global Settings
  location = var.location

  // Storage Account Parameters
  name                = var.ops_log_storage_account_name
  resource_group_name = var.resource_group_name
  storage_account     = var.ops_logging_storage_account

  // Storage Account Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Operations Network Resource: %s", var.ops_log_storage_account_name)
  }) # Tags to be applied to all resources
}

output "storage_accounts" {
  value     = module.mod_ops_logging_storage
  sensitive = true
}

#################################################
### STAGE 2: Build out Operations Networking  ###
#################################################

#
#
# Operations Virtual network
#
#
module "mod_ops_network" {
  source = "../../../../modules/Microsoft.Network/virtualNetworks"

  // Global Settings
  location = var.location

  // VNET Parameters
  vnet_name           = var.ops_virtual_network_name
  vnet_address_space  = var.ops_vnet_address_space
  resource_group_name = var.resource_group_name

  // VNET Resource Lock Parameters
  enable_resource_lock = var.enable_resource_locks
  lock_level           = var.lock_level

  // VNET Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Operations Network Resource: %s", var.ops_virtual_network_name)
  }) # Tags to be applied to all resources
}

#
#
# Operations Subnet
#
#
module "mod_ops_subnet" {
  depends_on = [module.mod_ops_network]
  source     = "../../../../modules/Microsoft.Network/subnets"

  // Global Settings
  location = var.location

  // Subnet Parameters
  resource_group_name  = var.resource_group_name
  virtual_network_name = module.mod_ops_network.virtual_network_name

  subnets = [
    {
      name : var.ops_subnet_name
      address_prefixes : [cidrsubnet(var.ops_vnet_subnet_address_space, 0, 0)]
      service_endpoints : var.ops_subnet_service_endpoints
      enforce_private_link_endpoint_network_policies : false
      enforce_private_link_service_network_policies : false
    }
  ]

  // Subnet Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Operations Network Resource: %s", var.ops_subnet_name)
  }) # Tags to be applied to all resources
}

#
#
# Route Table
#
#
module "mod_ops_routetable" {
  source = "../../../../modules/Microsoft.Network/routeTables"

  // Global Settings
  location = var.location

  // Route Table Parameters
  name                          = "ops-routetable"
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = true

  // Routetable Resource Lock Parameters
  enable_resource_lock = var.enable_resource_locks
  lock_level           = var.lock_level

  // Routetable Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Operations Network Resource: %s", "ops-routetable")
  }) # Tags to be applied to all resources

}

#
#
# Route Table
#
#
module "mod_ops_default_route" {
  source = "../../../../modules/Microsoft.Network/routeTables/route"

  // Route Table Route Parameters
  name                   = "default_ops_route"
  resource_group_name    = var.resource_group_name
  location               = var.location
  routetable_name        = module.mod_ops_routetable.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.firewall_private_ip
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [
    module.mod_ops_default_route
  ]

  create_duration = "30s"
}

# Associate the route table with the subnet
resource "azurerm_subnet_route_table_association" "routetable" {
  depends_on = [
    module.mod_ops_routetable,
    time_sleep.wait_30_seconds
  ]

  subnet_id      = module.mod_ops_subnet.subnet_ids[var.ops_subnet_name]
  route_table_id = module.mod_ops_routetable.id
}

#
#
# Network Security Group
#
#
module "mod_ops_network_nsg" {
  depends_on = [module.mod_ops_subnet]
  source     = "../../../../modules/Microsoft.Network/networkSecurityGroups"

  // Global Settings
  location = var.location

  // NSG Parameters
  name                = var.ops_network_security_group_name
  resource_group_name = var.resource_group_name

  // NSG Rules
  nsg_rules = var.ops_network_security_group_rules

  // NSG Resource Lock Parameters
  enable_resource_lock = var.enable_resource_locks
  lock_level           = var.lock_level

  // NSG Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Operations Network Resource: %s", var.ops_network_security_group_name)
  }) # Tags to be applied to all resources
}

# Associate the NSG with the subnet
resource "azurerm_subnet_network_security_group_association" "nsg" {
  depends_on = [
    module.mod_ops_network_nsg,
    time_sleep.wait_30_seconds
  ]
  subnet_id                 = module.mod_ops_subnet.subnet_ids[var.ops_subnet_name]
  network_security_group_id = module.mod_ops_network_nsg.id
}


