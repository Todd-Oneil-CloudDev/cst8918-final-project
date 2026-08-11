output "redis-name" {
  value = azurerm_redis_cache.redis.name
}

output "redis_id" {
  value = azurerm_redis_cache.redis.id
}

output "tls" {
  value = azurerm_redis_cache.redis.ssl_port
}

output "hostname" {
  value = azurerm_redis_cache.redis.hostname
}

output "key" {
  value     = azurerm_redis_cache.redis.primary_access_key
  sensitive = true
}