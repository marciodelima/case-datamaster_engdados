resource "azurerm_cognitive_account" "openai" {
  name                = "openai-ri"
  location            = "eastus2"
  resource_group_name = var.resource_group_name
  kind                = "OpenAI"
  sku_name            = "S0"
}

resource "azurerm_cognitive_deployment" "gpt-4o-mini" {
  name                 = "gpt-4o-mini"
  cognitive_account_id = azurerm_cognitive_account.openai.id

  model {
    format  = "OpenAI"
    name    = "gpt-4o-mini"
    version = "2024-07-18"
  }

  sku {
    name = "Standard"
  }
}

data "azurerm_key_vault" "openai_kv" {
  name                = var.keyvault_name
  resource_group_name = var.resource_group_name
}

# Armazena o endpoint no Key Vault
resource "azurerm_key_vault_secret" "openai_endpoint" {
  name         = "OpenAI-Endpoint"
  value        = azurerm_cognitive_account.openai.endpoint
  key_vault_id = data.azurerm_key_vault.openai_kv.id
}

data "azurerm_cognitive_account_keys" "openai_keys" {
  name                = azurerm_cognitive_account.openai.name
  resource_group_name = var.resource_group_name
}

resource "azurerm_key_vault_secret" "openai_key" {
  name         = "OpenAI-Key"
  value        = data.azurerm_cognitive_account_keys.openai_keys.key1
  key_vault_id = data.azurerm_key_vault.openai_kv.id
}

