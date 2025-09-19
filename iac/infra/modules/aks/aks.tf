resource "azurerm_kubernetes_cluster" "aks" {
  name                    = "aks-datamaster"
  location                = var.location
  resource_group_name     = var.resource_group
  kubernetes_version      = "1.31.3"
  oidc_issuer_enabled     = true
  sku_tier                = "Standard"
  dns_prefix              = "datamaster"
  private_cluster_enabled = true
  tags                    = var.tags

  default_node_pool {
    name                 = "default"
    min_count            = 1
    max_count            = 2
    enable_auto_scaling  = true
    orchestrator_version = "1.31.3"
    vnet_subnet_id       = azurerm_subnet.aks_subnet.id
    vm_size		 = "Standard_D2as_v6"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.integration_identity.id]
  }

  network_profile {
    network_plugin     = "azure"
    service_cidr       = "10.240.0.0/16"
    dns_service_ip     = "10.240.0.10"
    outbound_type      = "userDefinedRouting"
  }

  depends_on = [data.azurerm_user_assigned_identity.integration_identity, azurerm_subnet.aks_subnet, azurerm_public_ip.appgw_ip]
}

resource "azurerm_route_table" "aks_rt" {
  name                    = "aks-route-table"
  location                = var.location
  resource_group_name     = var.resource_group
}

resource "azurerm_subnet_route_table_association" "aks_rt_assoc" {
  subnet_id      = azurerm_subnet.aks_subnet.id
  route_table_id = azurerm_route_table.aks_rt.id
}



