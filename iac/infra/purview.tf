resource "azurerm_purview_account" "catalogo" {
  name                = "purview-datamaster"
  location            = var.location
  resource_group_name = var.resource_group_name
  identity {
    type = "SystemAssigned"
  }
  depends_on = [azurerm_storage_account.storage, null_resource.register_purview]
}

resource "azurerm_role_assignment" "purview_reader" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_purview_account.catalogo.identity[0].principal_id
  depends_on = [
    azurerm_purview_account.catalogo,
    azurerm_storage_account.storage
  ]
}

resource "azurerm_role_assignment" "purview_data_curator" {
  scope                = azurerm_purview_account.catalogo.id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_user_assigned_identity.integration_identity.principal_id
  depends_on = [
    azurerm_purview_account.catalogo
  ]
}

resource "null_resource" "register_purview" {
  provisioner "local-exec" {
    command = "az provider register --namespace Microsoft.Purview"
  }
}

