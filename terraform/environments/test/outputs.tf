# environments/test/outputs.tf
output "test_acr_login_server" {
  value = module.acr.login_server
}

output "test_aks_kube_config_raw" {
  value     = module.aks.kube-config
  sensitive = true
}

output "test_redis_hostname" {
  value = module.redis.hostname
}

output "test_redis_primary_access_key" {
  value     = module.redis.key
  sensitive = true
}

output "test_redis_tls" {
  value     = module.redis.tls
  sensitive = true
}

output "test_acr_pull_id" {
  value = azurerm_role_assignment.aks_acr_pull.id
}

output "test_acr_pull_principal" {
  value = azurerm_role_assignment.aks_acr_pull.principal_id
}

output "test_aks_kubelet_object_id" {
  value = module.aks.kubelet_object_id
}

output "resource_group" {
  value = data.terraform_remote_state.network.outputs.main_resource_group_name
}

