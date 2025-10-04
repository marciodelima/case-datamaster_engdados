#!/bin/bash
set -e

echo "Instalando Databricks CLI e jq..."
# sudo apt-get install -y jq || true
# curl -L https://github.com/databricks/cli/releases/download/v0.271.0/databricks_cli_0.271.0_linux_amd64.tar.gz -o databricks.tar.gz
# tar -xvzf databricks.tar.gz
# sudo mv databricks /usr/local/bin/

echo "Gerando token via Azure CLI..."
token_response=$(az account get-access-token --resource "$DATABRICKS_RESOURCE")
export DATABRICKS_AAD_TOKEN=$(jq -r .accessToken <<< "$token_response")
export DATABRICKS_HOST="https://${WORKSPACE_URL}"

echo "Configurando Databricks CLI..."
cat > ~/.databrickscfg <<EOF
[DEFAULT]
host = $DATABRICKS_HOST
token = $DATABRICKS_AAD_TOKEN
EOF

echo "Gerando token bootstrap para automações..."
BOOTSTRAP_TOKEN=$(databricks tokens create --comment "Bootstrap token" --lifetime-seconds 1209600 | jq -r ".token_value")

cat > ~/.databrickscfg <<EOF
[DEFAULT]
host = $DATABRICKS_HOST
token = $BOOTSTRAP_TOKEN
EOF

echo "Criando storage credential 'finance-cred'..."
databricks storage-credentials create --json '{
  "name": "finance-cred",
  "comment": "Credencial gerenciada",
  "azure_managed_identity": {
    "access_connector_id": "'"${ACCESS_CONNECTOR_ID}"'"
  }
}' || echo "Credencial já existe ou falhou."

echo "Registrando external location 'finance-ext'..."
databricks external-locations create --json '{
  "name": "finance-ext",
  "url": "'"${STORAGE_ROOT}"'",
  "credential_name": "finance-cred",
  "comment": "Local de dados do metastore",
  "read_only": false
}' || echo "Local já existe ou falhou."

echo "Detectando catálogo atual vinculado ao metastore..."
CATALOG_NAME=$(databricks catalogs list --output json | jq -r '.[] | select(.metastore_id=="'"$METASTORE_ID"'") | .name' | head -n 1)

if [ -z "$CATALOG_NAME" ]; then
  echo "Nenhum catálogo encontrado para o metastore $METASTORE_ID. Abortando."
  exit 1
fi

echo "Catálogo detectado: $CATALOG_NAME"

echo "Criando schemas no catálogo 'finance'..."
for schema in r-inv b-inv s-inv stage g-inv; do
  echo "Criando schema '$schema'..."
  databricks schemas create --json '{
    "name": "'"$schema"'",
    "catalog_name": "finance"
  }' || echo "Schema '$schema' já existe ou falhou."
done

echo "Criando policy padrão para clusters..."
cat <<EOF > policy.json
{
  "spark_version": { "type": "fixed", "value": "16.4.x-scala2.12" },
  "node_type_id": { "type": "fixed", "value": "Standard_D4pds_v6" },
  "autotermination_minutes": { "type": "fixed", "value": 20 },
  "is_single_node": {"type": "fixed", "value": true }
  "enable_elastic_disk": { "type": "fixed", "value": true }
}
EOF
databricks cluster-policies create --name "inv-policy" --definition "$(cat policy.json)" || echo "Policy já existe ou falhou."

echo "Criando cluster SQL para consultas..."
databricks clusters create --json '{
  "cluster_name": "finance-sql",
  "spark_version": "16.4.x-scala2.12",
  "node_type_id": "Standard_D4pds_v6",
  "is_single_node": true,
  "policy_id": "'"$(databricks cluster-policies list -o json | jq -r '.[] | select(.name=="inv-policy") | .policy_id')"'"
}' || echo "Cluster já existe ou falhou."

echo "Salvando token bootstrap no Azure Key Vault..."
az keyvault secret set --vault-name "$KEYVAULT_NAME" --name "databricks-bootstrap-token" --value "$BOOTSTRAP_TOKEN"

echo "Criando secret scope para AKV..."
KEYVAULT_DNS_NAME_CLEAN=$(echo "$KEYVAULT_DNS" | sed 's:/*$::')
curl -s -X POST "$DATABRICKS_HOST/api/2.0/secrets/scopes/create" \
  -H "Authorization: Bearer $BOOTSTRAP_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "scope": "finance-kv-secrets",
    "scope_backend_type": "AZURE_KEYVAULT",
    "initial_manage_principal": "users",
    "backend_azure_keyvault": {
      "resource_id": "'"${KEYVAULT_RESOURCE_ID}"'",
      "dns_name": "'"${KEYVAULT_DNS_NAME_CLEAN}"'"
    }
  }' || echo "Secret scope já existe ou falhou."

echo "Provisionamento Databricks concluído com sucesso."
