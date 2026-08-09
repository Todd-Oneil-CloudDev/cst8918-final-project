resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  resource_group_name = var.resource_group_name
  location            = var.region
  kubernetes_version = var.aks_version

  default_node_pool {
    name                = var.node_name
    vm_size             = "Standard_B2s"
    enable_auto_scaling = true
    min_count           = var.min
    max_count           = var.max
    node_count          = var.min
  }

  identity {
    type = "SystemAssigned"
  }
}