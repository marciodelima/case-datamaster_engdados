resource "azurerm_purview_account" "catalogo" {
  name                = "purview-datamaster"
  location            = var.location
  resource_group_name = var.resource_group_name
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "purview_reader" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_purview_account.purview.identity.principal_id
}

resource "null_resource" "ativar_scan" {
  provisioner "local-exec" {
    command = "bash ./ativar_scan_purview.sh"
  }

  depends_on = [
    azurerm_purview_account.purview,
    azurerm_storage_account.storage
  ]
}

