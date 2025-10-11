data "azurerm_storage_account" "existing_storage" {
  name                = var.existing_storage_account_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_role_assignment" "news_blob_access" {
  scope                = data.azurerm_storage_account.existing_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_function_app.news_producer.identity[0].principal_id
}

data "azurerm_key_vault" "kv" {
  name                = var.keyvault_name
  resource_group_name = var.resource_group_name
}

data "azurerm_eventhub_namespace" "existing_ns" {
  name                = var.eventhub_namespace_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_role_assignment" "news_keyvault_reader" {
  scope                = data.azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_function_app.news_producer.identity[0].principal_id
}

resource "azurerm_role_assignment" "news_eventhub_sender" {
  scope                = data.azurerm_eventhub_namespace.existing_ns.id
  role_definition_name = "Azure Event Hubs Data Sender"
  principal_id         = azurerm_linux_function_app.news_producer.identity[0].principal_id
}

resource "azurerm_role_assignment" "finance_blob_access" {
  scope                = data.azurerm_storage_account.existing_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_function_app.finance_csv_ingestor.identity[0].principal_id
}

resource "azurerm_role_assignment" "finance_keyvault_reader" {
  scope                = data.azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_function_app.finance_csv_ingestor.identity[0].principal_id
}

resource "azurerm_key_vault_access_policy" "news_producer_secrets_access" {
  key_vault_id = data.azurerm_key_vault.kv.id
  tenant_id    = var.tenant_id
  object_id    = azurerm_linux_function_app.news_producer.identity[0].principal_id

  secret_permissions = [
    "Get",
    "List"
  ]
}

resource "azurerm_key_vault_access_policy" "finance_csv_ingestor_secrets_access" {
  key_vault_id = data.azurerm_key_vault.kv.id
  tenant_id    = var.tenant_id
  object_id    = azurerm_linux_function_app.finance_csv_ingestor.identity[0].principal_id

  secret_permissions = [
    "Get",
    "List"
  ]
}

