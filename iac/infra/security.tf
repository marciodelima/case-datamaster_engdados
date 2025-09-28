resource "azurerm_role_assignment" "identity_storage_access" {
  principal_id         = data.azurerm_user_assigned_identity.integration_identity.principal_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = module.storage.storage_id
  depends_on = [
    module.storage
  ]
}

resource "azurerm_role_assignment" "identity_fabric_storage_access" {
  principal_id         = module.fabric.principal_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = module.storage.storage_id
  depends_on = [
    module.storage
  ]
}

resource "azurerm_role_assignment" "fabric_pg_access" {
  principal_id         = module.fabric.principal_id
  role_definition_name = "Contributor"
  scope                = module.postgres.server_id
  depends_on = [
    module.postgres
  ]
}

data "azurerm_resource_group" "fabric_rg" {
  name = var.resource_group_name
}

data "azuread_service_principal" "fabric_spn" {
  display_name = var.spn_name
}

resource "azurerm_role_assignment" "fabric_admin" {
  scope                = data.azurerm_resource_group.fabric_rg.id
  role_definition_name = "Contributor"
  principal_id         = data.azuread_service_principal.fabric_spn.object_id
}
