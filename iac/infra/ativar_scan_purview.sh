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

# Registrar o Storage como fonte de dados
az extension add --name purview
az purview account datasource create \
  --account-name $PURVIEW_NAME \
  --name "datalake-dados" \
  --resource-id "$STORAGE_ID" \
  --kind AzureStorage \
  --scan-name "scan-dados" \
  --scan-rule-set-name "AzureStorageDefault" \
  --recurrence "Daily" \
  --scan-trigger-type Schedule

echo "Fonte de dados registrada e scan agendado com sucesso."
