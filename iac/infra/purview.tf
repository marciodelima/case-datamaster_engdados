resource "azurerm_purview_account" "catalogo" {
  name                = "purview-datamaster"
  location            = var.location
  resource_group_name = var.resource_group_name
  identity {
    type = "SystemAssigned"
  }
  depends_on = [azurerm_storage_account.storage, null_resource.register_purview]
}

resource "azurerm_role_assignment" "purview_reader" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_purview_account.catalogo.identity[0].principal_id
  depends_on = [
    azurerm_purview_account.catalogo,
    azurerm_storage_account.storage
  ]
}

resource "azurerm_purview_datasource" "storage_datasource" {
  name                = "datalake-dados"
  purview_account_id = azurerm_purview_account.catalogo.id
  kind                = "AzureStorage"

  properties {
    resource_id = data.azurerm_storage_account.storage.id

    collection {
      type           = "CollectionReference"
      reference_name = "root"
    }
  }
  depends_on = [
    azurerm_purview_account.catalogo,
    azurerm_storage_account.storage
  ]
}

resource "null_resource" "purview_scan" {
  depends_on = [azurerm_purview_datasource.storage_datasource]

  provisioner "local-exec" {
    command = <<EOT
      ACCESS_TOKEN=$(az account get-access-token --resource https://purview.azure.net --query accessToken -o tsv)
      curl -X PUT "https://${azurerm_purview_account.purview.name}.scan.purview.azure.com/datasources/datalake-dados/scans/scan-dados?api-version=2023-09-01" \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "Content-Type: application/json" \
        -d '{
          "kind": "AzureStorage",
          "properties": {
            "scanRulesetName": "AzureStorageDefault",
            "scanRulesetType": "System",
            "trigger": {
              "recurrence": {
                "interval": 1,
                "frequency": "Day"
              },
              "type": "Schedule"
            }
          }
        }'
    EOT
    interpreter = ["bash", "-c"]
  }
}

