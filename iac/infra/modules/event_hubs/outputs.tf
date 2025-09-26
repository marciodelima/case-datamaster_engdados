output "eventhub_namespace_id" {
  description = "ID do namespace do Event Hub"
  value       = azurerm_eventhub_namespace.streaming_ns.id
}

output "eventhub_namespace_name" {
  description = "Nome do namespace do Event Hub"
  value       = azurerm_eventhub_namespace.streaming_ns.name
}

