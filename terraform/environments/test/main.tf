# pull data from remote data
data "terraform_remote_state" "network" {
  backend = "azurerm"

  config = {
    resource_group_name  = "cst8918-final-project-group-01-tfstate-rg"
    storage_account_name = "cst8918tfstategrp01"
    container_name       = "tfstate"
    key                  = "network.tfstate"
  }
}

module "acr" {
  source              = "../../modules/acr"
  name                = var.acr_name
  resource_group_name = data.terraform_remote_state.network.outputs.main_resource_group_name
  region              = data.terraform_remote_state.network.outputs.main_location
}

module "aks" {
  source = "../../modules/aks"

  aks_name            = var.aks_name
  resource_group_name = data.terraform_remote_state.network.outputs.main_resource_group_name
  node_name           = var.node_name
  region              = data.terraform_remote_state.network.outputs.main_location
  subnet_id           = data.terraform_remote_state.network.outputs.subnet_ids["test"]
  dns_prefix          = var.aks_dns_prefix
  aks_version         = var.aks_version
  service_cidr        = var.aks_service_cidr
  service_dns_ip      = var.aks_service_dns_ip
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = module.acr.acr_id
  role_definition_name = "AcrPull"
  principal_id         = module.aks.kubelet_object_id
}

module "redis" {
  source = "../../modules/redis"

  name                = var.redis_name
  resource_group_name = data.terraform_remote_state.network.outputs.main_resource_group_name
  region              = data.terraform_remote_state.network.outputs.main_location
}