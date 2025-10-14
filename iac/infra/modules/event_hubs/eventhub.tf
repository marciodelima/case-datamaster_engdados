data "azurerm_storage_account" "existing_storage" {
  name                = var.nome_storage
  resource_group_name = var.resource_group_name
}

resource "azurerm_eventhub_namespace" "streaming_ns" {
  name                = "datamaster-evt-namespace"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  capacity            = 1
  tags                = var.tags

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "eventhub_storage_writer" {
  scope                = data.azurerm_storage_account.existing_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_eventhub_namespace.streaming_ns.identity[0].principal_id
}

resource "azurerm_eventhub" "streaming_hub" {
  name              = "noticias_investimentos"
  namespace_id      = azurerm_eventhub_namespace.streaming_ns.id
  partition_count   = 1
  message_retention = 1

#  capture_description {
#    enabled             = true
#    encoding            = "Avro"
#    interval_in_seconds = 300
#    size_limit_in_bytes = 104857600

#    destination {
#      name                = "EventHubArchive.AzureBlockBlob"
#      storage_account_id  = data.azurerm_storage_account.existing_storage.id
#      blob_container_name = "dados"
#      archive_name_format = "raw/noticias/{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
#    }
#  }
}

