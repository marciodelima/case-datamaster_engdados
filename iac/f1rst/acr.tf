resource "azurerm_container_registry" "acr" {
  name                     = "acrregistry-datamaster"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  sku                      = "Premium"
  admin_enabled            = false
  identity {
    type = "UserAssigned"
    user_assigned_identity = {
      "${azurerm_user_assigned_identity.integration_identity.id}" = azurerm_user_assigned_identity.integration_identity.id
    }
  }
}

