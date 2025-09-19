data "azurerm_kubernetes_cluster" "aks" {
  name                = azurerm_kubernetes_cluster.aks.name
  resource_group_name = azurerm_kubernetes_cluster.aks.aks_resource_group
  depends_on          = [azurerm_kubernetes_cluster.aks]
}

resource "azurerm_public_ip" "nginx_ingress_ip" {
  name                = "aks-ingress-ip"
  location            = data.azurerm_kubernetes_cluster.aks.location
  resource_group_name = data.azurerm_kubernetes_cluster.aks.node_resource_group
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
    allow = "appgw"
    enviroment = "NAT Gateway"
  }
}

