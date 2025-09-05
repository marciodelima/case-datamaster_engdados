resource "kubernetes_namespace" "services" {
  for_each = toset(var.namespaces)

  metadata {
    name = each.key
  }
  depends_on = [azurerm_kubernetes_cluster.aks]
}

resource "kubernetes_service_account" "workload_sa" {
  for_each = toset(var.namespaces)

  metadata {
    name      = "${each.key}-sa"
    namespace = each.key
    annotations = {
      "azure.workload.identity/client-id" = data.azurerm_user_assigned_identity.integration_identity.id
    }
  }
  depends_on = [kubernetes_namespace.services]
}

resource "azurerm_federated_identity_credential" "federation" {
  for_each = toset(var.namespaces)

  name                = "${each.key}-federation"
  resource_group_name = var.resource_group
  parent_id           = data.azurerm_user_assigned_identity.integration_identity.id

  audience = ["api://AzureADTokenExchange"]
  issuer   = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  subject  = "system:serviceaccount:${each.key}:${each.key}-sa"
  depends_on = [kubernetes_namespace.services]
}

resource "helm_release" "keda" {
  name       = "keda"
  namespace  = "keda"
  repository = "https://kedacore.github.io/charts"
  chart      = "keda"
  version    = "2.13.0"

  create_namespace = false
  #provider = helm.aks
  depends_on = [kubernetes_namespace.services]
}

