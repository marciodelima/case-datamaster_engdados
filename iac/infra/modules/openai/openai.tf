resource "azurerm_cognitive_account" "openai" {
  name                = "openai-ri"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "OpenAI"
  sku_name            = "S0"
}

resource "azurerm_cognitive_deployment" "gpt4" {
  name                 = "gpt-4"
  cognitive_account_id = azurerm_cognitive_account.openai.id

  model {
    format  = "OpenAI"
    name    = "gpt-3.5-turbo"
    version = "2024-04-09"
  }

  sku {
    name = "Standard"
  }
}

