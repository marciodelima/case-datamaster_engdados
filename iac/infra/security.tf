resource "azurerm_role_assignment" "identity_storage_access" {
  principal_id         = data.azurerm_user_assigned_identity.integration_identity.principal_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = module.storage.storage_id
  depends_on = [
    module.storage
  ]
}

