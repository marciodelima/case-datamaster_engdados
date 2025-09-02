data "azurerm_client_config" "current" {}

resource "azuread_application" "github_app" {
  display_name = var.spn_name
}

resource "azuread_service_principal" "github_spn" {
  client_id = azuread_application.github_app.client_id
}

resource "azuread_application_password" "github_secret" {
  application_id        = azuread_application.github_app.id
  display_name          = "github-spn-secret"
  end_date = timeadd(timestamp(), "8760h") # 1 ano
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azuread_service_principal.github_spn.object_id
}

resource "azurerm_role_assignment" "kv_reader" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Reader"
  principal_id         = azuread_service_principal.github_spn.object_id
}

resource "azurerm_key_vault_access_policy" "github_owner_policy" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get",
    "Set",
    "Delete",
    "Recover",
    "List"
  ]
}

resource "azurerm_key_vault_access_policy" "github_spn_policy" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azuread_service_principal.github_spn.object_id

  secret_permissions = [
    "Get",
    "Set",
    "Delete",
    "Recover",
    "List"
  ]
}

resource "azurerm_key_vault_secret" "spn_password" {
  name         = "spn-client-secret"
  value        = azuread_application_password.github_secret.value
  key_vault_id = azurerm_key_vault.kv.id
  depends_on = [azurerm_key_vault_access_policy.github_spn_policy]
}

resource "azurerm_key_vault_secret" "spn_client_id" {
  name         = "spn-client-id"
  value        = azuread_application.github_app.client_id
  key_vault_id = azurerm_key_vault.kv.id
  depends_on = [azurerm_key_vault_access_policy.github_spn_policy]
}

resource "azurerm_key_vault_secret" "spn_tenant_id" {
  name         = "spn-tenant-id"
  value        = data.azurerm_client_config.current.tenant_id
  key_vault_id = azurerm_key_vault.kv.id
  depends_on = [azurerm_key_vault_access_policy.github_spn_policy]
}

resource "azurerm_role_assignment" "spn_owner" {
  scope                = azurerm_resource_group.rsg_datamaster.id
  role_definition_name = "Owner"
  principal_id         = azuread_service_principal.github_spn.object_id
}

