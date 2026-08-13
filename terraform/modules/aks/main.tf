resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  resource_group_name = var.resource_group_name
  location            = var.region
  kubernetes_version  = var.aks_version
  dns_prefix          = var.dns_prefix
  oidc_issuer_enabled = true

  default_node_pool {
    name                = var.node_name
    vm_size             = "Standard_B2s"
    enable_auto_scaling = true
    min_count           = var.min
    max_count           = var.max
    vnet_subnet_id      = var.subnet_id
  }

  network_profile {
    network_plugin = "azure"
    dns_service_ip = var.service_dns_ip
    service_cidr   = var.service_cidr
  }

  identity {
    type = "SystemAssigned"
  }
}