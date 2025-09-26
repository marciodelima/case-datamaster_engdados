resource "azurerm_eventhub_namespace" "streaming_ns" {
  name                = "datamaster-evt-namespace"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  capacity            = 1
  tags                = var.tags
}

resource "azurerm_eventhub" "streaming_hub" {
  name                = "topic_dados_streaming"
  namespace_id        = azurerm_eventhub_namespace.streaming_ns.id
  resource_group_name = var.resource_group_name
  partition_count     = 2
  message_retention   = 1
}

