resource "azurerm_container_registry" "acr" {
  name                     = "acrregistrydatamaster"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  sku                      = "Standard"
  admin_enabled            = false

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.integration_identity.id]
  }
}

