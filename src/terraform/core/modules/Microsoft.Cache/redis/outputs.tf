# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

output "redis_cache_id" {
    value = azurerm_redis_cache.redis_cache.id
}

output "redis_cache_location" {
    value = azurerm_redis_cache.redis_cache.location
}

output "redis_cache_connection_string" {
    value = azurerm_redis_cache.redis_cache.primary_connection_string
}

output "redis_cache_name" {
    value = azurerm_redis_cache.redis_cache.name
}