data "azurerm_function_app" "functions" {
  for_each            = toset(var.function_names)
  name                = each.key
  resource_group_name = var.resource_group_name
}

locals {
  function_ids = {
    for name in var.function_names :
    name => lookup(data.azurerm_function_app.functions, name, null) != null ? data.azurerm_function_app.functions[name].id : ""
  }

  finance_dashboard_json = jsonencode({
    lenses = {
      "0" = {
        order = 0
        parts = merge({
          "0" = {
            position = { x = 0, y = 0, rowSpan = 2, colSpan = 12 }
            metadata = {
              type = "Extension/HubsExtension/PartType/MarkdownPart"
              settings = {
                content = "# Observabilidade Financeira\n\nInfraestrutura • Dados • Banco • Funções"
              }
            }
          }
          "1" = {
            position = { x = 0, y = 2, rowSpan = 6, colSpan = 6 }
            metadata = {
              type   = "Extension/MetricsExplorerPart"
              inputs = { scope = var.databricks_id }
              settings = {
                Content = {
                  Version   = "1.0"
                  ChartType = "Line"
                  Metrics = [
                    { MetricNamespace = "Microsoft.Databricks/workspaces", MetricName = "ClusterCount", Aggregation = "Average" }
                  ]
                }
              }
            }
          }
          "2" = {
            position = { x = 6, y = 2, rowSpan = 6, colSpan = 6 }
            metadata = {
              type   = "Extension/MetricsExplorerPart"
              inputs = { scope = var.databricks_id }
              settings = {
                Content = {
                  Version   = "1.0"
                  ChartType = "Column"
                  Metrics = [
                    { MetricNamespace = "Microsoft.Databricks/workspaces", MetricName = "JobSuccessCount", Aggregation = "Total" },
                    { MetricNamespace = "Microsoft.Databricks/workspaces", MetricName = "JobFailureCount", Aggregation = "Total" }
                  ]
                }
              }
            }
          }
          "3" = {
            position = { x = 0, y = 8, rowSpan = 6, colSpan = 6 }
            metadata = {
              type   = "Extension/MetricsExplorerPart"
              inputs = { scope = var.storage_id }
              settings = {
                Content = {
                  Version   = "1.0"
                  ChartType = "Area"
                  Metrics = [
                    { MetricNamespace = "Microsoft.Storage/storageAccounts", MetricName = "UsedCapacity", Aggregation = "Average" },
                    { MetricNamespace = "Microsoft.Storage/storageAccounts", MetricName = "Transactions", Aggregation = "Total" }
                  ]
                }
              }
            }
          }
          "4" = {
            position = { x = 6, y = 8, rowSpan = 6, colSpan = 6 }
            metadata = {
              type   = "Extension/MetricsExplorerPart"
              inputs = { scope = var.eventhub_id }
              settings = {
                Content = {
                  Version   = "1.0"
                  ChartType = "Column"
                  Metrics = [
                    { MetricNamespace = "Microsoft.EventHub/namespaces", MetricName = "IncomingMessages", Aggregation = "Total" },
                    { MetricNamespace = "Microsoft.EventHub/namespaces", MetricName = "OutgoingMessages", Aggregation = "Total" }
                  ]
                }
              }
            }
          }
          "5" = {
            position = { x = 0, y = 14, rowSpan = 6, colSpan = 6 }
            metadata = {
              type   = "Extension/MetricsExplorerPart"
              inputs = { scope = var.postgres_id }
              settings = {
                Content = {
                  Version   = "1.0"
                  ChartType = "Line"
                  Metrics = [
                    { MetricNamespace = "Microsoft.DBforPostgreSQL/flexibleServers", MetricName = "cpu_percent", Aggregation = "Average" },
                    { MetricNamespace = "Microsoft.DBforPostgreSQL/flexibleServers", MetricName = "memory_percent", Aggregation = "Average" }
                  ]
                }
              }
            }
          }
          },
          {
            for idx, name in var.function_names :
            tostring(100 + idx) => {
              position = {
                x       = idx % 2 == 0 ? 0 : 6
                y       = 20 + floor(idx / 2) * 6
                rowSpan = 6
                colSpan = 6
              }
              metadata = {
                type   = "Extension/MetricsExplorerPart"
                inputs = { scope = local.function_ids[name] }
                settings = {
                  Content = {
                    Version   = "1.0"
                    ChartType = "Column"
                    Metrics = [
                      { MetricNamespace = "Microsoft.Web/sites", MetricName = "FunctionExecutionCount", Aggregation = "Total" },
                      { MetricNamespace = "Microsoft.Web/sites", MetricName = "Http5xx", Aggregation = "Total" }
                    ]
                  }
                }
              }
            }
        })
      }
    }
    metadata = {
      model = {
        timeRange = {
          value = {
            relative = {
              duration = 24
              timeUnit = 1
            }
          }
        }
      }
    }
  })

  jobs_dashboard_json = jsonencode({
    lenses = {
      "0" = {
        order = 0
        parts = {
          "0" = {
            position = { x = 0, y = 0, rowSpan = 2, colSpan = 12 }
            metadata = {
              type = "Extension/HubsExtension/PartType/MarkdownPart"
              settings = {
                content = "# Execução de Jobs Databricks"
              }
            }
          }
          "1" = {
            position = { x = 0, y = 2, rowSpan = 6, colSpan = 6 }
            metadata = {
              type   = "Extension/MetricsExplorerPart"
              inputs = { scope = var.databricks_id }
              settings = {
                Content = {
                  Version   = "1.0"
                  ChartType = "Column"
                  Metrics = [
                    { MetricNamespace = "Microsoft.Databricks/workspaces", MetricName = "JobSuccessCount", Aggregation = "Total" },
                    { MetricNamespace = "Microsoft.Databricks/workspaces", MetricName = "JobFailureCount", Aggregation = "Total" }
                  ]
                }
              }
            }
          }
          "2" = {
            position = { x = 6, y = 2, rowSpan = 6, colSpan = 6 }
            metadata = {
              type   = "Extension/MetricsExplorerPart"
              inputs = { scope = var.databricks_id }
              settings = {
                Content = {
                  Version   = "1.0"
                  ChartType = "Line"
                  Metrics = [
                    { MetricNamespace = "Microsoft.Databricks/workspaces", MetricName = "JobRunTime", Aggregation = "Average" }
                  ]
                }
              }
            }
          }
        }
      }
    }
    metadata = {
      model = {
        timeRange = {
          value = {
            relative = {
              duration = 24
              timeUnit = 1
            }
          }
        }
      }
    }
  })
}

resource "azurerm_portal_dashboard" "finance_dashboard" {
  name                = "finance-observability"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = { dash = "geral" }

  dashboard_properties = local.finance_dashboard_json
}

resource "azurerm_portal_dashboard" "jobs_dashboard" {
  name                = "jobs-execution-dashboard"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = { dash = "jobs databricks" }

  dashboard_properties = local.jobs_dashboard_json
}

