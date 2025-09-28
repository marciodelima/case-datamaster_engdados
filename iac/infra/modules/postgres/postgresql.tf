resource "azurerm_postgresql_flexible_server" "ri_db" {
  name                   = "finance-db-postgres-2025"
  resource_group_name    = var.resource_group_name
  location               = var.location
  administrator_login    = "adminuser"
  administrator_password = var.db_password
  version                = "13"
  storage_mb             = 32768
  sku_name               = "GP_Standard_D2s_v3"
  zone                   = "1"

  authentication {
    active_directory_auth_enabled = true
  }

  tags = {
    environment = "production"
  }
}

resource "azurerm_postgresql_flexible_server_database" "ri_db_main" {
  name       = "finance-db"
  server_id  = azurerm_postgresql_flexible_server.ri_db.id
  collation  = "en_US.utf8"
  charset    = "UTF8"
  depends_on = [azurerm_postgresql_flexible_server.ri_db]
}

resource "null_resource" "enable_pgvector" {
  provisioner "local-exec" {
    command = <<EOT
      PGPASSWORD=${var.db_password} psql \
        -h ${azurerm_postgresql_flexible_server.ri_db.fqdn} \
        -U adminuser \
        -d finance-db \
        -c "CREATE EXTENSION IF NOT EXISTS vector;"
    EOT
  }
  depends_on = [azurerm_postgresql_flexible_server_database.ri_db_main]
}

data "external" "github_runner_ip" {
  program = ["bash", "-c", "echo '{\"ip\": \"'$(curl -s https://ifconfig.me)'\"}'"]
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "github_actions_ip" {
  name                = "AllowGitHubActions"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_flexible_server.ri_db.name
  start_ip_address    = data.external.github_runner_ip.result.ip
  end_ip_address      = data.external.github_runner_ip.result.ip
}

resource "null_resource" "init_sql" {
  depends_on = [azurerm_postgresql_flexible_server.ri_db]

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOT
      sleep(60)
      echo "Executando init.sql no PostgreSQL..."
      PGPASSWORD=${var.db_password} psql \
        -h ${azurerm_postgresql_flexible_server.ri_db.fqdn} \
        -U adminuser \
        -d finance-db \
        -f ${path.module}/init.sql \
        --set ON_ERROR_STOP=on
    EOT
  }
}

