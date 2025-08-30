#!/bin/bash

set -e

REPO="marciodelima/case-datamaster_engdados"

echo "Terraform apply..."
terraform init
terraform apply -auto-approve

echo "Outputs do Terraform..."
AZURE_CLIENT_ID=$(terraform output -raw azure_client_id)
AZURE_CLIENT_SECRET=$(terraform output -raw azure_client_secret)
AZURE_TENANT_ID=$(terraform output -raw azure_tenant_id)
AZURE_CREDENTIALS=$(terraform output -raw azure_credentials_json)

echo "Criando secrets no GitHub..."
gh secret set ACR_LOGIN_SERVER --body "acrregistry-datamaster.azurecr.io" --repo $REPO
gh secret set ACR_NAME         --body "acrregistry-datamaster.azurecr.io" --repo $REPO
gh secret set AKS_RG           --body "rsg-datamaster" --repo $REPO
gh secret set AKS_NAME         --body "aks-datamaster" --repo $REPO

gh secret set AZURE_CLIENT_ID     --body "$AZURE_CLIENT_ID"     --repo $REPO
gh secret set AZURE_CLIENT_SECRET --body "$AZURE_CLIENT_SECRET" --repo $REPO
gh secret set AZURE_TENANT_ID     --body "$AZURE_TENANT_ID"     --repo $REPO
gh secret set AZURE_CREDENTIALS   --body "$AZURE_CREDENTIALS"   --repo $REPO

echo "Secrets criadas com sucesso!"
