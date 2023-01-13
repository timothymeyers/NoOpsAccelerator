# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

// This module creates the hub subnet and associated resources

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

#
#
# Hub Subnet
#
#
module "mod_subnet" {
  source = "../../../../modules/Microsoft.Network/subnets"

  // Global Settings
  location = var.location

  // Subnet Parameters
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name

  subnets = var.hub_subnets

  // Subnet Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
  }) # Tags to be applied to all resources
}

#
#
# Hub Network Security Group
#
#
module "mod_network_nsg" {
  depends_on = [module.mod_subnet]
  source     = "../../../../modules/Microsoft.Network/networkSecurityGroups"

  // Global Settings
  location = var.location

  // NSG Parameters
  name                = var.network_security_group_name
  resource_group_name = data.azurerm_resource_group.rg.name

  // NSG Rules Parameters
  nsg_rules = var.network_security_group_rules

  // NSG Resource Lock Parameters
  enable_resource_lock = true
  lock_level           = "CanNotDelete"

  // NSG Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("hub Network Resource: %s", var.network_security_group_name)
  }) # Tags to be applied to all resources
}

# Associate the NSG with the subnet
resource "azurerm_subnet_network_security_group_association" "nsg" {
  depends_on = [
    module.mod_network_nsg,
    time_sleep.wait_30_seconds
  ]
  subnet_id                 = module.mod_subnet.subnet_ids["hub-snet"]
  network_security_group_id = module.mod_network_nsg.id
}

#
#
# Route Table for Hub Subnet
#
#
module "mod_routetable" {
  source = "../../../../modules/Microsoft.Network/routeTables"

  // Global Settings
  location = var.location

  // Route Table Parameters
  name                          = var.routetable_name
  resource_group_name           = data.azurerm_resource_group.rg.name
  disable_bgp_route_propagation = true

  // Routetable Resource Lock Parameters
  enable_resource_lock = true
  lock_level           = "CanNotDelete"

  // Routetable Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Hub Network Resource: %s", "hub-routetable")
  }) # Tags to be applied to all resources

}

#
#
# Route Table Route for Hub Subnet
#
#
module "mod_default_route" {
  source = "../../../../modules/Microsoft.Network/routeTables/route"

  // Route Table Route Parameters
  name                   = "default_route"
  resource_group_name    = data.azurerm_resource_group.rg.name
  location               = var.location
  routetable_name        = module.mod_routetable.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.firewall_private_ip_address
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [
    module.mod_default_route
  ]

  create_duration = "30s"
}

resource "azurerm_subnet_route_table_association" "routetable_association" {
  depends_on = [
    module.mod_routetable,
    time_sleep.wait_30_seconds
  ]

  subnet_id      = module.mod_subnet.subnet_ids["hub-snet"]
  route_table_id = module.mod_routetable.id
}
