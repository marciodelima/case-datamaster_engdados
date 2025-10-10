resource "azurerm_service_plan" "func_plan" {
  name                = "func-plan"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "FC1"
  os_type             = "Linux"
}

resource "azurerm_application_insights" "finance_logs" {
  name                = "finance-appins-logs"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
}

resource "azurerm_function_app_flex_consumption" "news_producer" {
  depends_on                  = [azurerm_storage_account.news_storage]
  name                        = "news-producer-func"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  service_plan_id             = azurerm_service_plan.func_plan.id
 
  storage_container_type      = "blobContainer"
  storage_container_endpoint  = "${azurerm_storage_account.news_storage.primary_blob_endpoint}${azurerm_storage_container.news_code.name}"
  storage_authentication_type = "StorageAccountConnectionString"
  storage_access_key          = azurerm_storage_account.news_storage.primary_access_key
  runtime_name                = "python"
  runtime_version             = "3.10"
  maximum_instance_count      = 50
  instance_memory_in_mb       = 2048
  
  site_config {}

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE         = "1"
    PYTHON_ENABLE_WORKER_EXTENSIONS = "1"
    WEBSITE_HEALTHCHECK_MAXPINGFAILURES = "1"
    APPINSIGHTS_INSTRUMENTATIONKEY   = azurerm_application_insights.finance_logs.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.finance_logs.connection_string
    EVENTHUB_NAME      = var.eventhub_namespace_name
    EVENTHUB_NAMESPACE = "${var.eventhub_namespace_name}.servicebus.windows.net"
    STORAGE_URL        = "https://${var.existing_storage_account_name}.dfs.core.windows.net"
    KEYVAULT_URI       = "https://${var.keyvault_name}.vault.azure.net"
  }
}

resource "azurerm_function_app_flex_consumption" "ri_resumer" {
  depends_on                  = [azurerm_storage_account.ri_storage]
  name                       = "ri-resumer-func"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  service_plan_id            = azurerm_service_plan.func_plan.id

  storage_container_type      = "blobContainer"
  storage_container_endpoint  = "${azurerm_storage_account.ri_storage.primary_blob_endpoint}${azurerm_storage_container.ri_code.name}"
  storage_authentication_type = "StorageAccountConnectionString"
  storage_access_key          = azurerm_storage_account.ri_storage.primary_access_key
  runtime_name                = "python"
  runtime_version             = "3.10"
  maximum_instance_count      = 50
  instance_memory_in_mb       = 2048

  site_config {}

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE         = "1"
    PYTHON_ENABLE_WORKER_EXTENSIONS = "1"
    WEBSITE_HEALTHCHECK_MAXPINGFAILURES = "1"
    APPINSIGHTS_INSTRUMENTATIONKEY   = azurerm_application_insights.finance_logs.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.finance_logs.connection_string
    KEYVAULT_URI = "https://${var.keyvault_name}.vault.azure.net"
    STORAGE_URL  = "https://${var.existing_storage_account_name}.dfs.core.windows.net"
    DELTA_PATH   = "abfss://dados@${var.existing_storage_account_name}.dfs.core.windows.net/bronze/resultado_ri"
  }
}

resource "azurerm_function_app_flex_consumption" "ri_collector" {
  depends_on                 = [azurerm_storage_account.ri_collector_storage]
  name                       = "ri-collector-func"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  service_plan_id            = azurerm_service_plan.func_plan.id

  storage_container_type      = "blobContainer"
  storage_container_endpoint  = "${azurerm_storage_account.ri_collector_storage.primary_blob_endpoint}${azurerm_storage_container.ri_collector_code.name}"
  storage_authentication_type = "StorageAccountConnectionString"
  storage_access_key          = azurerm_storage_account.ri_collector_storage.primary_access_key
  runtime_name                = "python"
  runtime_version             = "3.10"
  maximum_instance_count      = 50
  instance_memory_in_mb       = 2048

  site_config {}

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE         = "1"
    PYTHON_ENABLE_WORKER_EXTENSIONS = "1"
    WEBSITE_HEALTHCHECK_MAXPINGFAILURES = "1"
    APPINSIGHTS_INSTRUMENTATIONKEY   = azurerm_application_insights.finance_logs.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.finance_logs.connection_string
    KEYVAULT_URI = "https://${var.keyvault_name}.vault.azure.net"
    STORAGE_URL  = "https://${var.existing_storage_account_name}.dfs.core.windows.net"
  }
}

resource "azurerm_function_app_flex_consumption" "finance_csv_ingestor" {
  depends_on                 = [azurerm_storage_account.finance_storage]
  name                       = "finance-csv-ingestor-func"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  service_plan_id            = azurerm_service_plan.func_plan.id

  storage_container_type      = "blobContainer"
  storage_container_endpoint  = "${azurerm_storage_account.finance_storage.primary_blob_endpoint}${azurerm_storage_container.finance_code.name}"
  storage_authentication_type = "StorageAccountConnectionString"
  storage_access_key          = azurerm_storage_account.finance_storage.primary_access_key
  runtime_name                = "python"
  runtime_version             = "3.10"
  maximum_instance_count      = 50
  instance_memory_in_mb       = 2048

  site_config {}

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE         = "1"
    PYTHON_ENABLE_WORKER_EXTENSIONS = "1"
    WEBSITE_HEALTHCHECK_MAXPINGFAILURES = "1"
    APPINSIGHTS_INSTRUMENTATIONKEY   = azurerm_application_insights.finance_logs.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.finance_logs.connection_string
    KEYVAULT_URI = "https://${var.keyvault_name}.vault.azure.net"
    STORAGE_URL  = "https://${var.existing_storage_account_name}.dfs.core.windows.net"
  }
}

resource "azurerm_function_app_flex_consumption" "postgres_ingestor" {
  depends_on                 = [azurerm_storage_account.postgres_storage]
  name                       = "postgres-ingestor-func"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  service_plan_id            = azurerm_service_plan.func_plan.id

  storage_container_type      = "blobContainer"
  storage_container_endpoint  = "${azurerm_storage_account.postgres_storage.primary_blob_endpoint}${azurerm_storage_container.postgres_code.name}"
  storage_authentication_type = "StorageAccountConnectionString"
  storage_access_key          = azurerm_storage_account.postgres_storage.primary_access_key
  runtime_name                = "python"
  runtime_version             = "3.10"
  maximum_instance_count      = 50
  instance_memory_in_mb       = 2048

  site_config {}

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE         = "1"
    PYTHON_ENABLE_WORKER_EXTENSIONS = "1"
    WEBSITE_HEALTHCHECK_MAXPINGFAILURES = "1"
    APPINSIGHTS_INSTRUMENTATIONKEY   = azurerm_application_insights.finance_logs.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.finance_logs.connection_string
    KEYVAULT_URI = "https://${var.keyvault_name}.vault.azure.net"
    STORAGE_URL  = "https://${var.existing_storage_account_name}.dfs.core.windows.net"
  }
}

resource "azurerm_function_app_flex_consumption" "news_sentiment_analyzer" {
  depends_on                 = [azurerm_storage_account.sentiment_storage]
  name                       = "news-sentiment-analyzer-func"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  service_plan_id            = azurerm_service_plan.func_plan.id

  storage_container_type      = "blobContainer"
  storage_container_endpoint  = "${azurerm_storage_account.sentiment_storage.primary_blob_endpoint}${azurerm_storage_container.sentiment_code.name}"
  storage_authentication_type = "StorageAccountConnectionString"
  storage_access_key          = azurerm_storage_account.sentiment_storage.primary_access_key
  runtime_name                = "python"
  runtime_version             = "3.10"
  maximum_instance_count      = 50
  instance_memory_in_mb       = 2048

  site_config {}

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE         = "1"
    PYTHON_ENABLE_WORKER_EXTENSIONS = "1"
    APPINSIGHTS_INSTRUMENTATIONKEY   = azurerm_application_insights.finance_logs.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.finance_logs.connection_string
    WEBSITE_HEALTHCHECK_MAXPINGFAILURES = "1"
    EVENTHUB_NAME      = var.eventhub_namespace_name
    EVENTHUB_NAMESPACE = "${var.eventhub_namespace_name}.servicebus.windows.net"
    KEYVAULT_URI = "https://${var.keyvault_name}.vault.azure.net"
    STORAGE_URL  = "https://${var.existing_storage_account_name}.dfs.core.windows.net"
    BRONZE_PATH  = "abfss://dados@${var.existing_storage_account_name}.dfs.core.windows.net/bronze"
  }
}

