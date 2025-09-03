resource "azurerm_kubernetes_cluster" "aks" {
  name                    = "aks-datamaster"
  location                = var.location
  resource_group_name     = var.resource_group
  dns_prefix              = "privatedns-datamaster"
  kubernetes_version      = "1.31.3"
  oidc_issuer_enabled     = true
  sku_tier                = "Standard"
  private_cluster_enabled = true
  tags                    = var.tags

  default_node_pool {
    name                 = "default"
    node_count           = 2
    vm_size              = "Standard_D4as_v6"
    enable_auto_scaling  = true
    min_count            = 2
    max_count            = 5
    orchestrator_version = "1.31.3"
    vnet_subnet_id       = azurerm_subnet.aks_subnet.id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.integration_identity.id]
  }

  azure_active_directory_role_based_access_control {
    managed = true
  }

  network_profile {
    network_plugin     = "azure"
    service_cidr       = "10.240.0.0/16"
    dns_service_ip     = "10.240.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
  }

  depends_on = [data.azurerm_user_assigned_identity.integration_identity, azurerm_subnet.aks_subnet]
}

