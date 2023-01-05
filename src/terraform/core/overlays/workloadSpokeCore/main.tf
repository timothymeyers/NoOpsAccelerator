# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module to deploy the Workload Network and it's components based on the Azure Mission Landing Zone conceptual architecture
DESCRIPTION: The following components will be options in this deployment
              Workload Virtual Network (Vnet)
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

###################################################
### STAGE 1: Build out workload storage account ###
###################################################

module "mod_workload_logging_storage" {
  source = "../../../../modules/Microsoft.Storage"

  //Global Settings
  location = var.location

  // Storage Account Parameters
  name                = var.workload_log_storage_account_name
  resource_group_name = var.resource_group_name
  storage_account     = var.workload_logging_storage_account

  // Storage Account Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Workload Network Resource: %s", var.workload_log_storage_account_name)
  }) # Tags to be applied to all resources
}

output "storage_accounts" {
  value     = module.mod_workload_logging_storage
  sensitive = true
}

#################################################
### STAGE 2: Build out Operations Networking  ###
#################################################

#
#
# Workload Virtual network
#
#
module "mod_workload_network" {
  source = "../../../../modules/Microsoft.Network/virtualNetworks"

  // Global Settings
  location = var.location

  // VNET Parameters
  vnet_name           = var.workload_virtual_network_name
  vnet_address_space  = var.workload_vnet_address_space
  resource_group_name = var.resource_group_name

  // VNET Resource Lock Parameters
  enable_resource_lock = true
  lock_level           = "CanNotDelete"

  // VNET Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Operations Network Resource: %s", var.workload_virtual_network_name)
  }) # Tags to be applied to all resources
}

#
#
# Operations Subnet
#
#
module "mod_workload_subnet" {
  depends_on = [module.mod_workload_network]
  source     = "../../../../modules/Microsoft.Network/subnets"

  // Global Settings
  location = var.location

  // Subnet Parameters
  resource_group_name  = var.resource_group_name
  virtual_network_name = module.mod_workload_network.virtual_network_name

  subnets = var.workloads_subnets

  // Subnet Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Operations Network Resource: %s", var.workload_subnet_name)
  }) # Tags to be applied to all resources
}

#
#
# Route Table
#
#
module "mod_workload_routetable" {
  source = "../../../../modules/Microsoft.Network/routeTables"

  // Global Settings
  location = var.location

  // Route Table Parameters
  name                          = "workload-routetable"
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = true

  // Routetable Resource Lock Parameters
  enable_resource_lock = true
  lock_level           = "CanNotDelete"

  // Routetable Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Operations Network Resource: %s", "workload-routetable")
  }) # Tags to be applied to all resources

}

#
#
# Route Table
#
#
module "mod_workload_default_route" {
  source = "../../../../modules/Microsoft.Network/routeTables/route"

  // Route Table Route Parameters
  name                   = "default_workload_route"
  resource_group_name    = var.resource_group_name
  location               = var.location
  routetable_name        = module.mod_workload_routetable.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.firewall_private_ip
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [
    module.mod_workload_default_route
  ]

  create_duration = "30s"
}

resource "azurerm_subnet_route_table_association" "routetable" {
  depends_on = [
    module.mod_workload_routetable,
    time_sleep.wait_30_seconds
  ]

  subnet_id      = module.mod_workload_subnet.id
  route_table_id = module.mod_workload_routetable.id
}

#
#
# Network Security Group
#
#
module "mod_workload_network_nsg" {
  depends_on = [module.mod_workload_subnet]
  source     = "../../../../modules/Microsoft.Network/networkSecurityGroups"

  // Global Settings
  location = var.location

  // NSG Parameters
  name                = var.workload_network_security_group_name
  resource_group_name = var.resource_group_name
  subnet_id           = module.mod_workload_subnet.id

  // NSG Rules Parameters
  nsg_rules = var.workload_network_security_group_rules

  // NSG Resource Lock Parameters
  enable_resource_lock = true
  lock_level           = "CanNotDelete"

  // NSG Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Workload Network Resource: %s", var.workload_network_security_group_name)
  }) # Tags to be applied to all resources
}

