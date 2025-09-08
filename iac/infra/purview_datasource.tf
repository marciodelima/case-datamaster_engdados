resource "null_resource" "create_purview_datasource" {
  provisioner "local-exec" {
    command = <<EOT
      az rest --method put \
        --uri "https://${azurerm_purview_account.catalogo.name}.purview.azure.com/scan/datasources/datalake-dados?api-version=2023-09-01" \
        --headers "Content-Type=application/json" \
        --body '{
          "kind": "AzureStorage",
          "properties": {
            "endpoint": "https://${azurerm_storage_account.storage.name}.dfs.core.windows.net/",
            "collection": {
              "referenceName": "${azurerm_purview_account.catalogo.name}"
            }
          }
        }'
    EOT
  }

  depends_on = [
    azurerm_purview_account.catalogo,
    azurerm_storage_account.storage
  ]
}

resource "null_resource" "create_purview_trigger" {
  provisioner "local-exec" {
    command = <<EOT
      az rest --method put \
        --uri "https://${azurerm_purview_account.catalogo.name}.purview.azure.com/scan/datasources/datalake-dados/scans/scan-datalake/triggers/default?api-version=2023-09-01" \
        --headers "Content-Type=application/json" \
        --body '{
          "properties": {
            "recurrenceInterval": null,
            "scanLevel": "Incremental",
            "state": "Enabled",
            "recurrence": {
              "interval": 1,
              "frequency": "Day",
              "schedule": {
                "hours": [0],
                "minutes": [0],
              }
            }
          }
        }'
    EOT
  }

  depends_on = [
    null_resource.create_purview_datasource
  ]
}

