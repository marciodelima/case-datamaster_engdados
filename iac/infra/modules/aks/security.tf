data "azurerm_subscription" "current" {}

resource "azurerm_role_assignment" "mi_operator_identity" {
  scope                = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group}"
  role_definition_name = "Managed Identity Operator"
  principal_id         = data.azurerm_user_assigned_identity.integration_identity.principal_id
}

resource "azurerm_role_assignment" "mi_operator_spn" {
  scope                = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group}"
  role_definition_name = "Managed Identity Operator"
  principal_id         = data.azuread_service_principal.github_spn.object_id
}

resource "azurerm_role_assignment" "aks_contributor_spn" {
  scope                = azurerm_kubernetes_cluster.aks.id
  role_definition_name = "Contributor"
  principal_id         = data.azuread_service_principal.github_spn.object_id
}

resource "azurerm_role_assignment" "acr_pull_spn" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = data.azuread_service_principal.github_spn.object_id
}

resource "azurerm_role_assignment" "aks_to_acr" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope                = data.azurerm_container_registry.acr.id
  depends_on           = [azurerm_kubernetes_cluster.aks]
}
