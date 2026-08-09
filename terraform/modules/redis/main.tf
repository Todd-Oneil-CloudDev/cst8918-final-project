resource "azurerm_redis_cache" "redis" {
  name = var.name
  resource_group_name = var.resource_group_name
  location = var.region
  sku_name = var.sku
  family = "C"
  capacity = 1
  non_ssl_port_enabled = false
  minimum_tls_version = "1.2"

  redis_configuration {}
}