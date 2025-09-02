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
    node_count           = 3
    vm_size              = "Standard_DS3_v2"
    enable_auto_scaling  = true
    min_count            = 3
    max_count            = 10
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
    network_plugin = "azure"
  }

  depends_on = [data.azurerm_user_assigned_identity.integration_identity, azurerm_subnet.aks_subnet]
}

