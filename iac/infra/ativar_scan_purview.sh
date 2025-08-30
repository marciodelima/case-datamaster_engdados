#!/bin/bash

# Variáveis
PURVIEW_NAME="purviewcatalogo"
STORAGE_NAME="datalakemedalhao"
RESOURCE_GROUP="rg-datalake"
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# Obter o ID do Storage
STORAGE_ID=$(az storage account show \
  --name $STORAGE_NAME \
  --resource-group $RESOURCE_GROUP \
  --query id -o tsv)

# Registrar o Storage como fonte de dados
az purview account datasource create \
  --account-name $PURVIEW_NAME \
  --name "datalake-dados" \
  --resource-id "$STORAGE_ID" \
  --kind AzureStorage \
  --scan-name "scan-dados" \
  --scan-rule-set-name "AzureStorageDefault" \
  --recurrence "Weekly" \
  --scan-trigger-type Schedule

echo "Fonte de dados registrada e scan agendado com sucesso."

