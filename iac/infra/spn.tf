data "azurerm_key_vault" "kv" {
  name                = var.keyvault_name
  resource_group_name = var.keyvault_rg
}
data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}

resource "azuread_application" "github_app" {
  display_name = var.spn_name
}

resource "azuread_service_principal" "github_spn" {
  application_id = azuread_application.github_app.application_id
}

resource "azuread_application_password" "github_secret" {
  application_object_id = azuread_application.github_app.id
  display_name          = "github-spn-secret"
  end_date_relative     = "87600h"
}

resource "azurerm_key_vault_secret" "spn_password" {
  name         = "spn-client-secret"
  value        = azuread_application_password.github_secret.value
  key_vault_id = data.azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "spn_client_id" {
  name         = "spn-client-id"
  value        = azuread_application.github_app.application_id
  key_vault_id = data.azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "spn_tenant_id" {
  name         = "spn-tenant-id"
  value        = data.azurerm_client_config.current.tenant_id
  key_vault_id = data.azurerm_key_vault.kv.id
}

resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = azuread_service_principal.github_spn.id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}

resource "azurerm_role_assignment" "aks_contributor" {
  principal_id         = azuread_service_principal.github_spn.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  scope                = azurerm_kubernetes_cluster.aks.id
}

resource "azurerm_role_assignment" "kv_reader" {
  principal_id         = azuread_service_principal.github_spn.id
  role_definition_name = "Key Vault Secrets User"
  scope                = data.azurerm_key_vault.kv.id
}

resource "azurerm_role_assignment" "storage_reader" {
  principal_id         = azuread_service_principal.github_spn.id
  role_definition_name = "Storage Blob Data Reader"
  scope                = azurerm_storage_account.sa.id
}

resource "azurerm_key_vault_access_policy" "github_spn_policy" {
  key_vault_id = data.azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azuread_service_principal.github_spn.id

  secret_permissions = [
    "get",
    "list"
  ]

  certificate_permissions = []
  key_permissions         = []
  storage_permissions     = []
}

