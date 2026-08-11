output "aks_id" {
  value = azurerm_kubernetes_cluster.aks.id
}

output "aks_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "kube-config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}

output "fqdn" {
  value = azurerm_kubernetes_cluster.aks.fqdn
}

output "identity" {
  value     = azurerm_kubernetes_cluster.aks.identity
  sensitive = true
}

output "kubelet_object_id" {
  value = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}