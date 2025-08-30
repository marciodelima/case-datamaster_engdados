data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}

resource "azuread_application" "github_app" {
  display_name = var.spn_name
}

resource "azuread_service_principal" "github_spn" {
  client_id = azuread_application.github_app.client_id
}

resource "azurerm_role_assignment" "aks_contributor" {
  principal_id         = azuread_service_principal.github_spn.object_id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  scope                = azurerm_kubernetes_cluster.aks.id
}

