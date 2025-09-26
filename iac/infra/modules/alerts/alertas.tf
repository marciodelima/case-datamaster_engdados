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

resource "azurerm_monitor_metric_alert" "job_failure_alert" {
  name                = "job-failure-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.databricks_wk_id]
  description         = "Alerta para falhas em jobs Databricks"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Databricks/workspaces"
    metric_name      = "JobFailureCount"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 0
  }

  action {
    action_group_id = azurerm_monitor_action_group.alert_email_group.id
  }
}

resource "azurerm_monitor_metric_alert" "job_duration_alert" {
  name                = "job-duration-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.databricks_wk_id]
  description         = "Alerta para jobs com duração acima do esperado"
  severity            = 3
  frequency           = "PT5M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Databricks/workspaces"
    metric_name      = "JobDuration"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 300000 # 5 minutos em ms
  }

  action {
    action_group_id = azurerm_monitor_action_group.alert_email_group.id
  }
}

