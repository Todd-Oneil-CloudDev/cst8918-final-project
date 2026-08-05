output "main_resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "main_network_name" {
  value = azurerm_virtual_network.main.name
}

output "main_network_id" {
  value = azurerm_virtual_network.main.id
}

output "subnet_ids" {
  description = "A map of environment name : subnet id e.g. subnet_ids['test']"
  value       = { for env, subnet in azurerm_subnet.subnets : env => subnet.id }
}

