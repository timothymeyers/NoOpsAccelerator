# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.


# NOTE: the Name used for Redis needs to be globally unique
resource "azurerm_redis_cache" "redis_cache" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  capacity            = var.capacity
  family              = var.family
  sku_name            = var.sku_name
  enable_non_ssl_port = var.enable_non_ssl_port
  minimum_tls_version = var.minimum_tls_version 

  redis_configuration {
  }
}