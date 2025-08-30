resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-datamaster"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "privatedns.datamaster"
  kubernetes_version  = "1.31.3"
  oidc_issuer_enabled = true
  tags                = var.tags

  default_node_pool {
    name                = "default"
    node_count          = 3
    vm_size             = "Standard_DS3_v2"
    enable_auto_scaling = true
    min_count           = 3
    max_count           = 10
    availability_zones  = ["1", "2", "3"]
  }

  identity {
    type = "UserAssigned"
    user_assigned_identity_id = azurerm_user_assigned_identity.integration_identity.id
  }

  role_based_access_control {
    enabled = true
    azure_active_directory {
      managed = true
    }
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
  }

  tags = {
    environment = "production"
  }
}

