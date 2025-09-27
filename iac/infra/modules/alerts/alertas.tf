resource "azurerm_monitor_action_group" "alert_email_group" {
  name                = "alert-email-group"
  resource_group_name = var.resource_group_name
  short_name          = "emailgrp"
  location            = "global"

  email_receiver {
    name                    = "admin-alert"
    email_address           = "marcio.lima.f1rst@gmail.com"
    use_common_alert_schema = true
  }

  tags = {
    environment = "production"
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert" "job_failure_alert" {
  name                = "job-failure-alert"
  resource_group_name = var.resource_group_name
  location            = var.location
  action {
    action_group_id = azurerm_monitor_action_group.alert_email_group.id
  }

  data_source_id = var.workspace_logs_id
  description    = "Alerta para falhas de jobs no Databricks"
  severity       = 2
  frequency      = 5
  time_window    = 5
  query          = <<QUERY
AzureDiagnostics
| where Category == "WorkspaceLogs"
| where OperationName == "JobRun"
| where RunState == "FAILED"
| summarize Falhas = count() by bin(TimeGenerated, 5m)
| where Falhas > 0
QUERY

  trigger {
    operator  = "GreaterThan"
    threshold = 0
  }

  criteria {
    metric_trigger {
      metric_column = "Falhas"
    }
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert" "job_duration_alert" {
  name                = "job-duration-alert"
  resource_group_name = var.resource_group_name
  location            = var.location
  action {
    action_group_id = azurerm_monitor_action_group.alert_email_group.id
  }

  data_source_id = var.workspace_logs_id
  description    = "Alerta para Jobs no Databricks com alto tempo de execução"
  severity       = 2
  frequency      = 5
  time_window    = 5
  query          = <<QUERY
AzureDiagnostics
| where Category == "WorkspaceLogs"
| where OperationName == "JobRun"
| where RunDuration > 3600
| summarize Longos = count() by bin(TimeGenerated, 5m)
QUERY

  trigger {
    operator  = "GreaterThan"
    threshold = 0
  }

  criteria {
    metric_trigger {
      metric_column = "Longos"
    }
  }
}

