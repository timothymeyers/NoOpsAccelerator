# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#---------------------------------------------------------
# Private Link for Storage Account - Default is "false" 
#---------------------------------------------------------
data "azurerm_virtual_network" "vnet01" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_endpoint" "pep1" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = format("%s-private-endpoint", element([for n in azurerm_storage_account.storage : n.name], 0))
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.existing_subnet_id
  tags                = merge({ "Name" = format("%s-private-endpoint", element([for n in azurerm_storage_account.storage : n.name], 0)) }, var.extra_tags, )

  private_service_connection {
    name                           = "storageaccount-privatelink"
    is_manual_connection           = false
    private_connection_resource_id = element([for i in azurerm_storage_account.storage : i.id], 0)
    subresource_names              = ["redisCache"]
  }
}

data "azurerm_private_endpoint_connection" "private-ip1" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = azurerm_private_endpoint.pep1.0.name
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_storage_account.storage]
}

resource "azurerm_private_dns_zone" "dnszone1" {
  count               = var.existing_private_dns_zone == null && var.enable_private_endpoint ? 1 : 0
  name                = var.environment == "public" ? "privatelink.vaultcore.azure.net" : "privatelink.vaultcore.usgovcloudapi.net"
  resource_group_name = var.resource_group_name
  tags                = merge({ "Name" = format("%s", "StorageAccount-Private-DNS-Zone") }, var.extra_tags, )
}

resource "azurerm_private_dns_zone_virtual_network_link" "vent-link1" {
  count                 = var.existing_private_dns_zone == null && var.enable_private_endpoint ? 1 : 0
  name                  = "vnet-private-zone-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.dnszone1.0.name
  virtual_network_id    = data.azurerm_virtual_network.vnet01.0.id
  tags                  = merge({ "Name" = format("%s", "vnet-private-zone-link") }, var.extra_tags, )
}

resource "azurerm_private_dns_a_record" "arecord1" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = element([for n in azurerm_storage_account.storage : n.name], 0)
  zone_name           = var.existing_private_dns_zone == null ? azurerm_private_dns_zone.dnszone1.0.name : var.existing_private_dns_zone
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [data.azurerm_private_endpoint_connection.private-ip1.0.private_service_connection.0.private_ip_address]
}