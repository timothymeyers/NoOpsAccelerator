# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module to deploy a CosmosDB with private endpoints to an Virtual Network
DESCRIPTION: The following components will be options in this deployment
            * CosmosDB with MongoDB API
            * Private Endpoints
            * Private DNS Zones
AUTHOR/S: jspinella
*/

# If the resource group name is not provided, create a new one
data "azurerm_resource_group" "cosmos_rg" {
  count = length(var.resource_group_name) > 0 ? 1 : 0
  name  = var.resource_group_name
}

# Create the CosmosDB
module "mod_cosmos_db" {
  source = "../../../modules/Microsoft.DocumentDB/databases"

  name                = var.cosmosdb_name
  location            = var.location
  resource_group_name = length(var.resource_group_name) > 0 ? data.azurerm_resource_group.cosmos_rg.name : var.resource_group_name
  account_kind        = var.cosmosdb_account_kind
}

# Create the private DNS zone for the ACR
module "mod_cosmos_db_private_dns_zone" {
  source                   = "../../../modules/Microsoft.Network/privateDnsZone"
  name                     = "privatelink.vaultcore.azure.net"
  resource_group_name      = length(var.resource_group_name) > 0 ? data.azurerm_resource_group.cosmos_rg.name : var.resource_group_name
  virtual_networks_to_link = var.virtual_networks_to_link
}

# Create the private endpoint for the ACR
module "mod_cosmos_db_private_endpoint" {
  source                         = "../../../modules/Microsoft.Network/privateEndpoints"
  name                           = "${module.mod_cosmos_db.name}PrivateEndpoint"
  location                       = var.location
  resource_group_name            = length(var.resource_group_name) > 0 ? data.azurerm_resource_group.cosmos_rg.name : var.resource_group_name
  subnet_id                      = var.vnet_subnet_id
  tags                           = var.tags
  private_connection_resource_id = module.mod_cosmos_db.id
  is_manual_connection           = false
  subresource_name               = "vault"
  private_dns_zone_group_name    = "CosmosDbPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.mod_cosmos_db_private_dns_zone.id]
}
