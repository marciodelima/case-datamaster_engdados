resource "azurerm_role_assignment" "identity_storage_access" {
  principal_id         = data.azurerm_user_assigned_identity.integration_identity.principal_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = module.storage.storage_id
  depends_on = [
    module.storage
  ]
}

resource "azurerm_role_assignment" "identity_storage_access_dbx" {
  principal_id         = module.databricks.access_connector_principal_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = module.storage.storage_id
  depends_on = [
    module.storage
  ]
}

resource "azurerm_role_assignment" "access_connector_keyvault_access" {
  scope                = data.azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.databricks.access_connector_principal_id

  depends_on = [
    module.databricks
  ]
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault_access_policy" "github_owner_policy" {
  key_vault_id = data.azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = module.databricks.access_connector_principal_id

  secret_permissions = [
    "Get", "Set", "Delete", "Recover", "List"
  ]

  depends_on = [
    module.databricks
  ]
}


