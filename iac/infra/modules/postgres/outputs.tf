output "server_id" {
  value = azurerm_postgresql_flexible_server.ri_db.id
}

output "fqdn" {
  value = azurerm_postgresql_flexible_server.ri_db.fqdn
}

output "postgres_connection_string" {
  description = "Connection string do PostgreSQL para uso nas Azure Functions"
  value       = "Host=${azurerm_postgresql_flexible_server.postgres.name}.postgres.database.azure.com;Port=5432;Database=${azurerm_postgresql_flexible_server.ri_db.administrator_login};User Id=${azurerm_postgresql_flexible_server.ri_db.administrator_login}@${azurerm_postgresql_flexible_server.ri_db.name};Password=${azurerm_postgresql_flexible_server.ri_db.administrator_password};Ssl Mode=Require"
  sensitive   = true
}

