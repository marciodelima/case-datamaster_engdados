output "workspace_id" {
  description = "ID do workspace Databricks"
  value       = azurerm_databricks_workspace.dbx.id
}

output "workspace_name" {
  description = "Nome do workspace Databricks"
  value       = azurerm_databricks_workspace.dbx.name
}

output "workspace_url" {
  description = "URL do workspace Databricks"
  value       = azurerm_databricks_workspace.dbx.workspace_url
}

output "access_connector_id" {
  value = azurerm_databricks_access_connector.finance.id
}

output "access_connector_principal_id" {
  value = azurerm_databricks_access_connector.finance.identity[0].principal_id
}

