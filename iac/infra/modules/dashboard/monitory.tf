resource "azurerm_portal_dashboard" "finance_dashboard" {
  name                = "finance-observability"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = { dash = "geral" }

  dashboard_properties = templatefile("${path.module}/dashboard.tftpl", {
    databricks_id = var.databricks_id
    storage_id    = var.storage_id
    eventhub_id   = var.eventhub_id
  })
}

resource "azurerm_portal_dashboard" "jobs_dashboard" {
  name                = "jobs-execution-dashboard"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = { dash = "jobs databricks" }

  dashboard_properties = templatefile("${path.module}/dash_jobs.tftpl", {
    databricks_id = var.databricks_id
  })
}

