data "azurerm_subscription" "current" {}

data "azurerm_resource_group" "fabric_rg" {
  name = var.resource_group_name
}

data "azuread_service_principal" "fabric_spn" {
  display_name = var.spn_name
}

resource "azurerm_role_definition" "fabric_admin_role" {
  name               = "Fabric Admin"
  scope              = data.azurerm_subscription.current.id
  description        = "Permissão para gerenciar capacidades e workspaces do Microsoft Fabric"
  assignable_scopes  = [data.azurerm_subscription.current.id]

  permissions {
    actions = [
      "Microsoft.Fabric/capacities/*",
      "Microsoft.Fabric/workspaces/*",
      "Microsoft.Fabric/*",
      "Microsoft.Resources/subscriptions/resourceGroups/read",
      "Microsoft.Authorization/*/read"
    ]
    not_actions = []
  }
}

resource "azurerm_role_assignment" "fabric_admin" {
  scope              = data.azurerm_resource_group.fabric_rg.id
  role_definition_id = azurerm_role_definition.fabric_admin_role.role_definition_resource_id
  principal_id       = data.azuread_service_principal.fabric_spn.object_id
}

