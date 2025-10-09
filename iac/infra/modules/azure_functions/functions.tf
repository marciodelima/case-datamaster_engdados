resource "azurerm_app_service_plan" "func_plan" {
  name                = "func-plan"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "FunctionApp"
  reserved            = true
  
  sku {
    tier = "FlexConsumption"
    size = "FC1"
  }
}

resource "azurerm_application_insights" "finance_logs" {
  name                = "finance-appins-logs"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
}

resource "azurerm_function_app" "news_producer" {
  name                       = "news-producer-func"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  app_service_plan_id        = azurerm_app_service_plan.func_plan.id
  storage_account_name       = azurerm_storage_account.news_storage.name
  storage_account_access_key = azurerm_storage_account.news_storage.primary_access_key
  version                    = "~4"
  os_type                    = "linux"
  
  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "python"
    PYTHON_ENABLE_WORKER_EXTENSIONS = "1"
    WEBSITE_RUN_FROM_PACKAGE = "1"
    APPINSIGHTS_INSTRUMENTATIONKEY = data.azurerm_application_insights.finance_logs.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = data.azurerm_application_insights.finance_logs.connection_string    
    EVENTHUB_NAME      = var.eventhub_namespace_name
    EVENTHUB_NAMESPACE = "${var.eventhub_namespace_name}.servicebus.windows.net"
    STORAGE_URL        = "https://${var.existing_storage_account_name}.dfs.core.windows.net"
    KEYVAULT_URI       = "https://${var.keyvault_name}.vault.azure.net"
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
  os_type                    = "linux"

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "python"
    PYTHON_ENABLE_WORKER_EXTENSIONS = "1"
    WEBSITE_RUN_FROM_PACKAGE = "1"
    APPINSIGHTS_INSTRUMENTATIONKEY = data.azurerm_application_insights.finance_logs.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = data.azurerm_application_insights.finance_logs.connection_string    
    KEYVAULT_URI = "https://${var.keyvault_name}.vault.azure.net"
    STORAGE_URL  = "https://${var.existing_storage_account_name}.dfs.core.windows.net"
    DELTA_PATH   = "abfss://dados@${var.existing_storage_account_name}.dfs.core.windows.net/bronze/resultado_ri"
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
  os_type                    = "linux"

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "python"
    PYTHON_ENABLE_WORKER_EXTENSIONS = "1"
    WEBSITE_RUN_FROM_PACKAGE = "1"
    APPINSIGHTS_INSTRUMENTATIONKEY = data.azurerm_application_insights.finance_logs.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = data.azurerm_application_insights.finance_logs.connection_string    
    KEYVAULT_URI = "https://${var.keyvault_name}.vault.azure.net"
    STORAGE_URL  = "https://${var.existing_storage_account_name}.dfs.core.windows.net"
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
  os_type                    = "linux"

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    STORAGE_URL              = "https://${var.existing_storage_account_name}.dfs.core.windows.net"
    KEYVAULT_URI             = "https://${var.keyvault_name}.vault.azure.net"
    FUNCTIONS_WORKER_RUNTIME = "python"
    PYTHON_ENABLE_WORKER_EXTENSIONS = "1"
    WEBSITE_RUN_FROM_PACKAGE = "1"
    APPINSIGHTS_INSTRUMENTATIONKEY = data.azurerm_application_insights.finance_logs.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = data.azurerm_application_insights.finance_logs.connection_string    
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
  os_type                    = "linux"

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "python"
    PYTHON_ENABLE_WORKER_EXTENSIONS = "1"
    WEBSITE_RUN_FROM_PACKAGE = "1"
    APPINSIGHTS_INSTRUMENTATIONKEY = data.azurerm_application_insights.finance_logs.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = data.azurerm_application_insights.finance_logs.connection_string    
    KEYVAULT_URI = "https://${var.keyvault_name}.vault.azure.net"
    STORAGE_URL  = "https://${var.existing_storage_account_name}.dfs.core.windows.net"
  }
}

resource "azurerm_function_app" "news_sentiment_analyzer" {
  name                       = "news-sentiment-analyzer-func"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  app_service_plan_id        = azurerm_app_service_plan.func_plan.id
  storage_account_name       = azurerm_storage_account.sentiment_storage.name
  storage_account_access_key = azurerm_storage_account.sentiment_storage.primary_access_key
  version                    = "~4"
  os_type                    = "linux"

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "python"
    PYTHON_ENABLE_WORKER_EXTENSIONS = "1"
    WEBSITE_RUN_FROM_PACKAGE = "1"
    APPINSIGHTS_INSTRUMENTATIONKEY = data.azurerm_application_insights.finance_logs.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = data.azurerm_application_insights.finance_logs.connection_string    
    EVENTHUB_NAME      = var.eventhub_namespace_name
    EVENTHUB_NAMESPACE = "${var.eventhub_namespace_name}.servicebus.windows.net"
    KEYVAULT_URI = "https://${var.keyvault_name}.vault.azure.net"
    STORAGE_URL  = "https://${var.existing_storage_account_name}.dfs.core.windows.net"
    BRONZE_PATH  = "abfss://dados@${var.existing_storage_account_name}.dfs.core.windows.net/bronze"
  }
}

