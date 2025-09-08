resource "azurerm_public_ip" "appgw_ip" {
  name                = "aks-ingress-ip"
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    allow = "appgw"
    enviroment = "aks"
  }
}
