resource "azurerm_kubernetes_cluster" "aks" {
  name                    = "aks-datamaster"
  location                = var.location
  resource_group_name     = var.resource_group
  dns_prefix              = "privatedns-datamaster"
  kubernetes_version      = "1.31.3"
  oidc_issuer_enabled     = true
  sku_tier                = "Standard"
  private_cluster_enabled = false
  tags                    = var.tags

  default_node_pool {
    name                 = "default"
    node_count           = 1
    vm_size              = "Standard_D2as_v6"
    enable_auto_scaling  = true
    min_count            = 1
    max_count            = 2
    orchestrator_version = "1.31.3"
    vnet_subnet_id       = azurerm_subnet.aks_subnet.id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.integration_identity.id]
  }

  network_profile {
    network_plugin     = "azure"
    service_cidr       = "10.240.0.0/16"
    dns_service_ip     = "10.240.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
  }

  depends_on = [data.azurerm_user_assigned_identity.integration_identity, azurerm_subnet.aks_subnet]
}

