output "aks_cluster_name" {
  description = "Nome do cluster AKS"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "dns_zone_name" {
  description = "Zona DNS pública"
  value       = azurerm_dns_zone.dns.name
}

output "application_gateway_ip" {
  description = "IP público do Application Gateway"
  value       = azurerm_public_ip.appgw_ip.ip_address
}

output "private_dns_zone" {
  description = "Zona DNS privada"
  value       = azurerm_private_dns_zone.datamaster_dns.name
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

