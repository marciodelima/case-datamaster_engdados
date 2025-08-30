output "storage_account_name" {
  value = azurerm_storage_account.storage.name
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "aks_cluster_name" {
  description = "Nome do cluster AKS"
  value       = var.aks_cluster_name
}

output "dns_zone_name" {
  description = "Zona DNS pública"
  value       = azurerm_dns_zone.dns.name
}

output "eventhub_namespace" {
  description = "Namespace do Event Hub"
  value       = azurerm_eventhub_namespace.streaming_ns.name
}

output "eventhub_name" {
  description = "Nome do Event Hub"
  value       = azurerm_eventhub.streaming_hub.name
}

output "application_gateway_ip" {
  description = "IP público do Application Gateway"
  value       = azurerm_public_ip.appgw_ip.ip_address
}

output "private_dns_zone" {
  description = "Zona DNS privada"
  value       = azurerm_private_dns_zone.datamaster_dns.name
}

