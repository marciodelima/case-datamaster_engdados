#!/bin/bash
set -e

echo "Instalando databricks CLI e jq..."
pip uninstall -y databricks-cli || true
curl -Lk https://github.com/databricks/cli/releases/download/v0.270.0/databricks_cli_0.270.0_linux_amd64.tar.gz -o databricks.tar.gz
tar -xvzf databricks.tar.gz
sudo mv databricks /usr/local/bin/

sudo apt-get install -y jq

echo "Autenticando via Azure AD..."
token_response=$(az account get-access-token --resource "$DATABRICKS_RESOURCE")
export DATABRICKS_AAD_TOKEN=$(jq -r .accessToken <<< "$token_response")
export DATABRICKS_HOST="https://${WORKSPACE_URL}"

cat > ~/.databrickscfg <<EOF
[DEFAULT]
host = $DATABRICKS_HOST
token = $DATABRICKS_AAD_TOKEN
EOF


echo "Gerando token bootstrap..."
BOOTSTRAP_TOKEN=$(databricks tokens create --comment "Bootstrap token" --lifetime-seconds 1209600 | jq -r ".token_value")

cat > ~/.databrickscfg <<EOF
[DEFAULT]
host = $DATABRICKS_HOST
token = $BOOTSTRAP_TOKEN
EOF

echo "Criando usuário admin..."
databricks users create --user-name "$ADMIN_EMAIL" --active || true

echo "Verificando se o grupo 'admins' existe..."
GROUP_EXISTS=$(databricks groups list -o json | jq -e '.[] | select(.displayName=="admins")' > /dev/null && echo "yes" || echo "no")
if [ "$GROUP_EXISTS" = "no" ]; then
  echo "Criando grupo 'admins'..."
  databricks groups create --display-name admins
else
  echo "Grupo 'admins' já existe."
fi

echo "Adicionando usuário ao grupo 'admins'..."
ADMIN_ID=$(databricks users list -o json | jq -r '.[] | select(.userName=="'"$ADMIN_EMAIL"'") | .id')
GROUP_ID=$(databricks groups list -o json | jq -r '.[] | select(.displayName=="admins") | .id')

databricks groups patch "$GROUP_ID" --json '{
  "schemas": ["urn:ietf:params:scim:api:messages:2.0:PatchOp"],
  "Operations": [
    {
      "op": "add",
      "path": "members",
      "value": [
        {
          "value": "'"$ADMIN_ID"'"
        }
      ]
    }
  ]
}' || true

echo "Adicionando usuário ao grupo 'account-admins'..."
ACCOUNT_HOST="https://accounts.azuredatabricks.net"
curl -kvs -X PATCH "$ACCOUNT_HOST/api/2.0/accounts/me/groups/account-admins" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "schemas": ["urn:ietf:params:scim:api:messages:2.0:PatchOp"],
    "Operations": [{
      "op": "add",
      "path": "members",
      "value": [{"value": "'"$ADMIN_ID"'"}]
    }]
  }'

echo "Gerando token admin pessoal..."
TOKEN=$(databricks account-access-tokens create --json '{
  "lifetime_seconds": 1209600,
  "comment": "Admin token gerado via script",
  "user_id": "'"${ADMIN_ID}"'"
}' | jq -r '.token_value')

STORAGE_ROOT="abfss://dados@${STORAGE_NAME}.dfs.core.windows.net/"

echo "Salvando token no Azure Key Vault..."
az keyvault secret set --vault-name "$KEYVAULT_NAME" --name "databricks-admin-token" --value "$TOKEN"

export DATABRICKS_TOKEN="$TOKEN"
unset ARM_CLIENT_ID
unset ARM_CLIENT_SECRET
unset ARM_TENANT_ID

echo "Obtendo metastore ID Atual..."
METASTORE_ID=$(databricks metastores list --output json | jq -r '.metastores[0].id')

echo "Trocando nome - metastore ID..."
databricks metastores update --json '{
  "metastore_id": "'"${METASTORE_ID}"'",
  "new-name": "'"${METASTORE_NAME}"'" 
}' || true

echo "Associando workspace ao metastore..."
databricks metastores assign "$WORKSPACE_ID" --json '{
  "metastore_id": "'"${METASTORE_ID}"'",
  "default_catalog_name": "main"
}' || true

echo "Criando storage credential 'finance-cred'..."
databricks storage-credentials create --json '{
  "name": "finance-cred",
  "comment": "Credencial gerenciada",
  "azure_managed_identity": {
    "access_connector_id": "'"${ACCESS_CONNECTOR_ID}"'"
  }
}' || echo "Credencial já existe, ignorando erro."

echo "Registrando external location 'finance-ext'..."
databricks external-locations create --json '{
  "name": "finance-ext",
  "url": "'"${STORAGE_ROOT}"'",
  "credential_name": "finance-cred",
  "comment": "Local de dados do metastore",
  "read_only": false
}'

echo "Criando catálogo 'finance'..."
databricks catalogs create --json '{
  "name": "finance",
  "comment": "Catálogo financeiro de investimentos",
  "metastore-id": "$METASTORE_ID"
}' || echo "Catálogo já existe, ignorando erro."

echo "Criando schemas no catálogo 'finance'..."
for schema in r-inv b-inv s-inv stage g-inv; do
  echo "Criando schema '$schema'..."
  databricks schemas create --json '{
    "name": "'"$schema"'",
    "catalog_name": "finance"
  }' || echo "Schema já existe" 
done

echo "Criando policy padrão para clusters..."
cat <<EOF > policy.json
{
  "spark_version": { "type": "fixed", "value": "14.3.x-scala2.12" },
  "node_type_id": { "type": "fixed", "value": "Standard_DS3_v2" },
  "autotermination_minutes": { "type": "fixed", "value": 30 },
  "enable_elastic_disk": { "type": "fixed", "value": true },
  "spark_conf.spark.sql.parquet.compression.codec": { "type": "fixed", "value": "snappy" },
  "spark_conf.spark.serializer": { "type": "fixed", "value": "org.apache.spark.serializer.KryoSerializer" },
  "spark_conf.spark.sql.execution.arrow.pyspark.enabled": { "type": "fixed", "value": true },
  "spark_conf.spark.sql.adaptive.enabled": { "type": "fixed", "value": true },
  "spark_conf.spark.sql.shuffle.partitions": { "type": "fixed", "value": "200" },
  "spark_conf.spark.databricks.io.cache.enabled": { "type": "fixed", "value": true },
  "spark_conf.spark.sql.parquet.filterPushdown": { "type": "fixed", "value": true },
  "spark_conf.spark.sql.parquet.mergeSchema": { "type": "fixed", "value": false },
  "spark_conf.spark.sql.autoBroadcastJoinThreshold": { "type": "fixed", "value": "104857600" }
}
EOF
databricks cluster-policies create --name "inv-policy" --definition "$(cat policy.json)" || true

echo "Criando cluster SQL para consultas..."
databricks clusters create --json '{
  "cluster_name": "finance-sql",
  "spark_version": "14.3.x-scala2.12",
  "node_type_id": "Standard_DS3_v2",
  "policy_id": "'"$(databricks cluster-policies list -o json | jq -r '.[] | select(.name=="inv-policy") | .policy_id')"'", 
  "num_workers": 1,
}' || true

echo "Subindo token para GitHub Actions..."
gh auth status || gh auth login --with-token <<< "$GH_TOKEN"
gh secret set DATABRICKS_ADMIN_TOKEN \
  --body "$TOKEN" \
  --repo "$GITHUB_REPO"

echo "Criando secret pro AKV"
KEYVAULT_DNS_NAME_CLEAN=$(echo "$KEYVAULT_DNS" | sed 's:/*$::')
curl -Xkv POST "$DATABRICKS_HOST/api/2.0/secrets/scopes/create" \
  -H "Authorization: Bearer $DATABRICKS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "scope": "finance-kv-secrets",
    "scope_backend_type": "AZURE_KEYVAULT",
    "initial_manage_principal": "users",
    "backend_azure_keyvault": {
      "resource_id": "'"${KEYVAULT_RESOURCE_ID}"'",
      "dns_name": "'"${KEYVAULT_DNS_NAME_CLEAN}"'"
    }
  }'

echo "Provisionamento Databricks concluído com sucesso."
