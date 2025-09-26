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

