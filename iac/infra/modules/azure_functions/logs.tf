locals {
  function_apps = {
    news_producer           = azurerm_linux_function_app.news_producer.id
    finance_csv_ingestor    = azurerm_linux_function_app.finance_csv_ingestor.id
  }
}

resource "azurerm_monitor_diagnostic_setting" "functions_diag" {
  for_each                   = local.function_apps
  name                       = "diag-${each.key}"
  target_resource_id         = each.value
  log_analytics_workspace_id = var.azurerm_log_analytics_workspace_id

  enabled_log {
    category = "FunctionAppLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
  
  lifecycle {
    ignore_changes = [name]
  }  
}

