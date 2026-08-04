output "backend_resource_group_name" {
  value = azurerm_resource_group.tfstate.name
}

output "backend_storage_account_name" {
  value = azurerm_storage_account.tfstate.name
}

output "backend_container_name" {
  value = azurerm_storage_container.tfstate.name
}

output "arm_access_key" {
  value     = azurerm_storage_account.tfstate.primary_access_key
  sensitive = true
}

output "backend_config_snippet" {
  description = "Copy this into the backend block of any environment's backend.tf, then set your own 'key'"
  value       = <<-EOT
    backend "azurerm" {
      resource_group_name   = "${azurerm_resource_group.tfstate.name}"
      storage_account_name  = "${azurerm_storage_account.tfstate.name}"
      container_name        = "${azurerm_storage_container.tfstate.name}"
      key                   = "<environment>.tfstate"  # e.g. dev.tfstate, test.tfstate, prod.tfstate
    }
  EOT
}
