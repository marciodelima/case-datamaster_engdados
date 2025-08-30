resource "azurerm_role_assignment" "identity_storage_access" {
  principal_id         = azurerm_user_assigned_identity.integration_identity.principal_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_storage_account.storage.id
}

resource "azurerm_role_assignment" "purview_data_curator" {
  scope                = azurerm_purview_account.purview.id
  role_definition_name = "Purview Data Curator"
  principal_id         = azurerm_user_assigned_identity.spark_identity.principal_id
}

