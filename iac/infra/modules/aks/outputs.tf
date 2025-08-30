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

