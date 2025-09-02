data "azurerm_subscription" "current" {}

resource "azurerm_role_assignment" "identity_storage_access" {
  principal_id         = data.azurerm_user_assigned_identity.integration_identity.principal_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_storage_account.storage.id
  depends_on = [
    azurerm_storage_account.storage
  ]
}

resource "azurerm_role_assignment" "purview_data_curator" {
  scope                = azurerm_purview_account.catalogo.id
  role_definition_name = "Purview Data Curator"
  principal_id         = data.azurerm_user_assigned_identity.integration_identity.principal_id
  depends_on = [
    azurerm_purview_account.catalogo
  ]
}

resource "null_resource" "register_purview" {
  provisioner "local-exec" {
    command = "az provider register --namespace Microsoft.Purview"
  }
}

resource "azurerm_role_assignment" "policy_contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Resource Policy Contributor"
  principal_id         = data.azurerm_user_assigned_identity.integration_identity.principal_id
}

