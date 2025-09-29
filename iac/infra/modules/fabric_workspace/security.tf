data "azurerm_resource_group" "fabric_rg" {
  name = var.resource_group_name
}

data "azuread_service_principal" "fabric_spn" {
  display_name = var.spn_name
}

resource "azurerm_role_assignment" "fabric_admin" {
  scope                = data.azurerm_resource_group.fabric_rg.id
  role_definition_name = "Fabric Admin"
  principal_id         = data.azuread_service_principal.fabric_spn.object_id
}

