output "storage_account_name" {
  value = azurerm_storage_account.storage.name
}

output "fabric_workspace_id" {
  value = module.fabric.id
}

output "databricks_workspace_url" {
  value = module.databricks.workspace_url
}

