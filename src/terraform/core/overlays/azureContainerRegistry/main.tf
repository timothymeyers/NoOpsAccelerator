# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module to deploy a Container Registry to the an Network
DESCRIPTION: The following components will be options in this deployment
                Container Registry
                User Assigned Managed Identity
                private DNS Zone
                private endpoint
                diagnostic setting
AUTHOR/S: jspinella
*/

# Create a user assigned managed identity for the ACR
module "acr_identity" {
  source = "../../modules/Microsoft.ManagedIdentity"

  location            = var.location
  resource_group_name = var.resource_group_name
  name                = var.acr_name # This is the name of the ACR
  tags = merge(var.tags, {
    DeployedBy = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}

# Create the ACR
module "acr" {
  source = "../../modules/Microsoft.ContainerRegistry"

  location            = var.location
  resource_group_name = var.resource_group_name
  name                = var.acr_name
  sku                 = coalesce(var.acr_sku, "Premium")
  admin_enabled       = coalesce(var.acr_admin_enabled, false)
  acr_identity_id     = module.acr_identity.identity_id
  tags = merge(var.tags, {
    DeployedBy = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}

# Create the private DNS zone for the ACR
module "acr_private_dns_zone" {
  source                   = "../../modules/Microsoft.Network/privateDnsZone"
  name                     = "privatelink.azurecr.io"
  resource_group_name      = var.resource_group_name
  virtual_networks_to_link = var.virtual_networks_to_link
}

# Create the private endpoint for the ACR
module "acr_private_endpoint" {
  source                         = "../../modules/Microsoft.Network/privateEndpoints"
  name                           = "${module.acr.name}PrivateEndpoint"
  location                       = var.location
  resource_group_name            = var.resource_group_name
  subnet_id                      = var.vnet_subnet_id
  tags                           = var.tags
  private_connection_resource_id = module.acr.id
  is_manual_connection           = false
  subresource_name               = "registry"
  private_dns_zone_group_name    = "AcrPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.acr_private_dns_zone.id]
}

