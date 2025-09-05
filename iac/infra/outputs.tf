output "storage_account_name" {
  value = azurerm_storage_account.storage.name
}

output "eventhub_namespace" {
  description = "Namespace do Event Hub"
  value       = azurerm_eventhub_namespace.streaming_ns.name
}

output "eventhub_name" {
  description = "Nome do Event Hub"
  value       = azurerm_eventhub.streaming_hub.name
}

