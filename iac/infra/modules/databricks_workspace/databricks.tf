resource "azurerm_databricks_workspace" "dbx" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "premium"
}

resource "azurerm_databricks_access_connector" "unity_catalog" {
  name                = "unity-catalog-access-connector"
  resource_group_name = azurerm_databricks_workspace.dbx.resource_group_name
  location            = azurerm_databricks_workspace.dbx.location
  identity {
    type = "SystemAssigned"
  }
  depends_on = [azurerm_databricks_workspace.dbx]
}

resource "azurerm_databricks_access_connector" "finance" {
  name                = "finance-access-connector"
  resource_group_name = azurerm_databricks_workspace.dbx.resource_group_name
  location            = azurerm_databricks_workspace.dbx.location
  identity {
    type = "SystemAssigned"
  }
  depends_on = [azurerm_databricks_workspace.dbx]
}

