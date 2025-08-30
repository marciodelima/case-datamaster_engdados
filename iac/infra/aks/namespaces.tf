resource "kubernetes_namespace" "services" {
  for_each = toset(var.namespaces)

  metadata {
    name = each.key
  }
}

resource "kubernetes_service_account" "workload_sa" {
  for_each = toset(var.namespaces)

  metadata {
    name      = "${each.key}-sa"
    namespace = each.key
    annotations = {
      "azure.workload.identity/client-id" = azurerm_user_assigned_identity.integration_identity.id
    }
  }
}

resource "azurerm_federated_identity_credential" "federation" {
  for_each = toset(var.namespaces)

  name                = "${each.key}-federation"
  resource_group_name = var.resource_group
  parent_id           = azurerm_user_assigned_identity.integration_identity.id

  audience = ["api://AzureADTokenExchange"]
  issuer   = azurerm_kubernetes_cluster.main.oidc_issuer_url
  subject  = "system:serviceaccount:${each.key}:${each.key}-sa"
}


