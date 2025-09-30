resource "azurerm_app_service_plan" "func_plan" {
  name                = "func-plan"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_function_app" "news_producer" {
  name                       = "news-producer-func"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  app_service_plan_id        = azurerm_app_service_plan.func_plan.id
  storage_account_name       = azurerm_storage_account.news_storage.name
  storage_account_access_key = azurerm_storage_account.news_storage.primary_access_key
  version                    = "~4"
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_function_app" "ri_resumer" {
  name                       = "ri-resumer-func"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  app_service_plan_id        = azurerm_app_service_plan.func_plan.id
  storage_account_name       = azurerm_storage_account.ri_storage.name
  storage_account_access_key = azurerm_storage_account.ri_storage.primary_access_key
  version                    = "~4"
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_function_app" "ri_collector" {
  name                       = "ri-collector-func"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  app_service_plan_id        = azurerm_app_service_plan.func_plan.id
  storage_account_name       = azurerm_storage_account.ri_collector_storage.name
  storage_account_access_key = azurerm_storage_account.ri_collector_storage.primary_access_key
  version                    = "~4"
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_function_app" "finance_csv_ingestor" {
  name                       = "finance-csv-ingestor-func"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  app_service_plan_id        = azurerm_app_service_plan.func_plan.id
  storage_account_name       = azurerm_storage_account.finance_storage.name
  storage_account_access_key = azurerm_storage_account.finance_storage.primary_access_key
  version                    = "~4"
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_function_app" "postgres_ingestor" {
  name                       = "postgres-ingestor-func"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  app_service_plan_id        = azurerm_app_service_plan.func_plan.id
  storage_account_name       = azurerm_storage_account.postgres_storage.name
  storage_account_access_key = azurerm_storage_account.postgres_storage.primary_access_key
  version                    = "~4"
  identity {
    type = "SystemAssigned"
  }
}

