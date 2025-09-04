#!/bin/bash

# Variáveis
PURVIEW_NAME="purview-datamaster"
STORAGE_NAME="datamasterstore"
RESOURCE_GROUP="rsg-datamaster"
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# Obter o ID do Storage
STORAGE_ID=$(az storage account show \
  --name $STORAGE_NAME \
  --resource-group $RESOURCE_GROUP \
  --query id -o tsv)
  
PURVIEW_ENDPOINT="https://${PURVIEW_NAME}.scan.purview.azure.com"
ACCESS_TOKEN=$(az account get-access-token --resource https://purview.azure.net --query accessToken -o tsv)

curl -X PUT "${PURVIEW_ENDPOINT}/datasources/datalake-dados?api-version=2023-09-01" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "kind": "AzureStorage",
    "properties": {
      "resourceId": "'"$STORAGE_ID"'",
      "collection": {
        "type": "CollectionReference",
        "referenceName": "root"
      }
    }
  }'

curl -X PUT "${PURVIEW_ENDPOINT}/datasources/datalake-dados/scans/scan-dados?api-version=2023-09-01" \
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

echo "Fonte de dados registrada e scan agendado com sucesso."
