#
# Private endpoint
#

module "private_endpoint" {
  source   = "../../Microsoft.Network/privateEndpoints"
  for_each = var.private_endpoints

  private_connection_resource_id = azurerm_redis_cache.redis.id
  name                           = each.value.name
  location                       = var.location
  resource_group_name            = var.resource_group_name
  subnet_id                      = each.value.subnet_id
  tags                           = local.tags
  private_dns                    = var.private_dns
}
