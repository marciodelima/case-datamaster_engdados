resource "azurerm_role_assignment" "aks_to_acr" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope                = data.azurerm_container_registry.acr.id
  depends_on           = [azurerm_kubernetes_cluster.aks]
}

resource "azurerm_role_assignment" "ip_permission" {
  scope                = azurerm_public_ip.appgw_ip.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  depends_on           = [azurerm_kubernetes_cluster.aks]
}
