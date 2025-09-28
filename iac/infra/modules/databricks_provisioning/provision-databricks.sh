#!/bin/bash
set -e

echo "Instalando databricks CLI e jq..."
pip uninstall -y databricks-cli || true

pip install databricks-cli --upgrade
curl -Lk https://github.com/databricks/cli/releases/download/v0.270.0/databricks_cli_0.270.0_linux_amd64.tar.gz -o databricks.tar.gz
tar -xvzf databricks.tar.gz
sudo mv databricks /usr/local/bin/

sudo apt-get install -y jq

echo "Autenticando via Azure AD..."
token_response=$(az account get-access-token --resource 2ff814a6-3304-4ab8-85cb-cd0e6f879c1d)
export DATABRICKS_AAD_TOKEN=$(jq -r .accessToken <<< "$token_response")

echo "Logando no workspace Databricks..."
databricks auth login --aad-token --host "https://${WORKSPACE_URL}"

export DATABRICKS_HOST="https://${WORKSPACE_URL}"

echo "Gerando token bootstrap..."
BOOTSTRAP_TOKEN=$(databricks tokens create --comment "Bootstrap token" --lifetime-seconds 1209600 | jq -r ".token_value")

echo "Autenticando com token bootstrap..."
databricks auth login --host "$DATABRICKS_HOST" --token "$BOOTSTRAP_TOKEN"

echo "Criando usuário admin..."
databricks users create --user-name "$ADMIN_EMAIL" --workspace-access true || true

echo "Adicionando ao grupo admins..."
ADMIN_ID=$(databricks users list | jq -r ".[] | select(.userName==\"$ADMIN_EMAIL\") | .id")
GROUP_ID=$(databricks groups list | jq -r ".[] | select(.displayName==\"admins\") | .id")
databricks groups add-member --group-id "$GROUP_ID" --user-id "$ADMIN_ID"

echo "Gerando token pessoal..."
TOKEN=$(databricks tokens create --comment "Admin token" --lifetime-seconds 1209600 | jq -r ".token_value")

echo "Criando catálogo 'finance' e schemas..."
databricks catalogs create --name finance --comment "Catálogo financeiro de investimentos"
for schema in r_inv b_inv s_inv stage g_inv; do
  databricks schemas create --catalog-name finance --name "$schema"
done

echo "Criando secret scope com Azure Key Vault..."
databricks secrets create-scope --scope inv_scope \
  --scope-backend-type AZURE_KEYVAULT \
  --resource-id "$KEYVAULT_RESOURCE_ID" \
  --dns-name "$KEYVAULT_DNS"

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
databricks cluster-policies create --name "inv-policy" --definition "$(cat policy.json)"

echo "Salvando token no Azure Key Vault..."
az keyvault secret set --vault-name "$KEYVAULT_NAME" --name "databricks-admin-token" --value "$TOKEN"

echo "Subindo token para GitHub Actions..."
gh secret set DATABRICKS_ADMIN_TOKEN --body "$TOKEN" --repo "$GITHUB_REPO"

echo "Provisionamento Databricks concluído com sucesso."
