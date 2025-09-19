resource "azurerm_public_ip" "appgw_ip" {
  name                = "aks-ingress-ip"
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    allow = "appgw"
    enviroment = "aks-nginx"
  }
}

resource "azurerm_public_ip" "nat_ip" {
  name                = "nat-ip"
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    enviroment = "NAT Gateway"
  }
}

