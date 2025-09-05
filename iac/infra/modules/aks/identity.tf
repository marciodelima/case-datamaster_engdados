data "azurerm_user_assigned_identity" "integration_identity" {
  name                = "integration-identity"
  resource_group_name = var.resource_group
}

resource "azuread_application" "github_app" {
  display_name = var.spn_name
}

data "azuread_service_principal" "github_spn" {
  client_id = data.azuread_application.github_app.client_id
}

