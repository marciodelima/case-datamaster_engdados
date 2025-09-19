locals {
  node_resource_group_name = format("MC_%s_%s_%s", var.resource_group, azurerm_kubernetes_cluster.aks.name, var.location)
  depends_on          = [azurerm_kubernetes_cluster.aks]
}

resource "azurerm_public_ip" "nginx_ingress_ip" {
  name                = "aks-ingress-ip"
  location            = var.location
  resource_group_name = local.node_resource_group_name
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

