# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# This module deploys a Front Door to the specified resource group.
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor

resource "azurerm_cdn_frontdoor_profile" "main" {
  name                     = var.frontdoor_name
  resource_group_name      = var.resource_group_name
  response_timeout_seconds = 120
  sku_name                 = var.frontdoor_sku
}

# Default Front Door endpoint
resource "azurerm_cdn_frontdoor_endpoint" "default" {
  name    = "${local.prefix}-primaryendpoint" # needs to be a gloablly unique name
  enabled = true

  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
}

resource "azurerm_cdn_frontdoor_custom_domain" "global" {
  count                    = var.custom_fqdn != "" ? 1 : 0
  name                     = "CustomDomainFrontendEndpoint"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id

  host_name   = var.custom_fqdn
  dns_zone_id = data.azurerm_dns_zone.customdomain[0].id

  tls {
    certificate_type    = "ManagedCertificate"
    minimum_tls_version = "TLS12"
  }
}

resource "azurerm_cdn_frontdoor_custom_domain_association" "global" {
  count                          = var.custom_fqdn != "" ? 1 : 0
  cdn_frontdoor_custom_domain_id = azurerm_cdn_frontdoor_custom_domain.global[0].id
  cdn_frontdoor_route_ids = setunion(
    [azurerm_cdn_frontdoor_route.globalstorage.id],
    azurerm_cdn_frontdoor_route.staticstorage.*.id,
    azurerm_cdn_frontdoor_route.backendapi.*.id
  )
}