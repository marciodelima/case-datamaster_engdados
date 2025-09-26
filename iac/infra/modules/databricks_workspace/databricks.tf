resource "azurerm_databricks_workspace" "dbx" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "premium"
}

data "databricks_group" "admins" {
  display_name = "admins"
}

resource "databricks_user" "marcio" {
  user_name        = "marcio.lima.f1rst@gmail.com"
  workspace_access = true
}

resource "databricks_group_member" "marcio_admin" {
  group_id  = data.databricks_group.admins.id
  member_id = databricks_user.marcio.id
}

