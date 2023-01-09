# Copyright (c) Microsoft Corporation.mod_subnet
# Licensed under the MIT License.

#
#
# Spoke Subnet
#
#
module "mod_subnet" {
  source     = "../../../../modules/Microsoft.Network/subnets"

  // Global Settings
  location = var.location

  // Subnet Parameters
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name

  name                                          = var.name
  address_prefixes                              = var.vnet_subnet_address_space
  service_endpoints                             = var.subnet_service_endpoints
  private_endpoint_network_policies_enabled     = var.private_endpoint_network_policies_enabled
  private_link_service_network_policies_enabled = var.private_link_service_network_policies_enabled

  // Subnet Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Spoke Network Resource: %s", var.name)
  }) # Tags to be applied to all resources
}

#
#
# Spoke Network Security Group
#
#
module "mod_network_nsg" {
  depends_on = [module.mod_subnet]
  source     = "../../../../modules/Microsoft.Network/networkSecurityGroups"

  // Global Settings
  location = var.location

  // NSG Parameters
  name                = var.network_security_group_name
  resource_group_name = var.resource_group_name
 
  // NSG Rules Parameters
  nsg_rules = var.network_security_group_rules

  // NSG Resource Lock Parameters
  enable_resource_lock = var.enable_resource_locks
  lock_level           = var.lock_level

  // NSG Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Spoke Network Resource: %s", var.network_security_group_name)
  }) # Tags to be applied to all resources
}

# Associate the NSG with the subnet
resource "azurerm_subnet_network_security_group_association" "nsg" {
  depends_on = [
    module.mod_network_nsg,
    time_sleep.wait_30_seconds
  ]
  subnet_id                 = module.mod_subnet.id
  network_security_group_id = module.mod_network_nsg.id
}

#
#
# Route Table for Spoke Subnet
#
#
module "mod_routetable" {
  source = "../../../../modules/Microsoft.Network/routeTables"

  // Global Settings
  location = var.location

  // Route Table Parameters
  name                          = var.routetable_name
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = true

  // Routetable Resource Lock Parameters
  enable_resource_lock = var.enable_resource_locks
  lock_level           = "CanNotDelete"

  // Routetable Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Spoke Network Resource: %s", "spoke-routetable")
  }) # Tags to be applied to all resources

}

#
#
# Route Table Route for Spoke Subnet
#
#
module "mod_default_route" {
  source = "../../../../modules/Microsoft.Network/routeTables/route"

  // Route Table Route Parameters
  name                   = "${var.name}_route"
  resource_group_name    = var.resource_group_name
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

  subnet_id      = module.mod_subnet.id
  route_table_id = module.mod_routetable.id
}


