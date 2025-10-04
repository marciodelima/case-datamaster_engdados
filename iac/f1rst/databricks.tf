resource "azurerm_databricks_workspace" "dbx" {
  name                = var.name_databricks
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "premium"
}

data "azurerm_databricks_access_connector" "unity_catalog" {
  name                = "unity-catalog-access-connector"
  resource_group_name = "databricks-rg-${var.resource_group_name}"
  depends_on          = [azurerm_databricks_workspace.dbx]
}

resource "null_resource" "provision_databricks" {
  provisioner "local-exec" {
    command = "bash ${path.module}/databricks_user.sh"

    environment = {
      WORKSPACE_URL       = azurerm_databricks_workspace.dbx.workspace_url
      ADMIN_EMAIL         = var.admin_email
      DATABRICKS_RESOURCE = var.databricks_resource
      REGION              = var.location
      WORKSPACE_ID        = azurerm_databricks_workspace.dbx.id
    }
  }
  depends_on = [azurerm_databricks_workspace.dbx]
}

