resource "azurerm_resource_group" "rg" {
  name     = "${var.rg}-${var.group_number}"
  location = var.location
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.group_number}-main-network"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  address_space = ["10.0.0.0/14"]
}

resource "azurerm_subnet" "subnets" {
  for_each             = var.subnet_map
  name                 = "${var.group_number}-${each.key}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.main.name

  address_prefixes = [each.value]
}