output "aks_cluster_name" {
  description = "Nome do cluster AKS"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "nginx_ingress_ip" {
  value = azurerm_public_ip.nginx_ingress_ip.ip_address
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config
}

output "host" {
  value = azurerm_kubernetes_cluster.aks.kube_config[0].host
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate
  sensitive = true
}

output "client_key" {
  value     = azurerm_kubernetes_cluster.aks.kube_config[0].client_key
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate
  sensitive = true
}

