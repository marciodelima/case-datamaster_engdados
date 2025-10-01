resource "azurerm_databricks_workspace" "dbx" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "premium"
}

resource "azurerm_databricks_access_connector" "finance" {
  name                = "finance-access-connector"
  resource_group_name = var.resource_group_name
  location            = var.location
  identity {
    type = "SystemAssigned"
  }
}

