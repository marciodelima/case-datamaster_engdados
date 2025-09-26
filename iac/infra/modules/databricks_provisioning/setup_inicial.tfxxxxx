provider "databricks" {
  alias = "workspace"
  host  = var.workspace_url
  token = var.workspace_token
}

# 1. Cluster policy padrão
resource "databricks_cluster_policy" "default_job_policy" {
  provider = databricks.workspace
  name     = "default-job-policy"

  definition = jsonencode({
    "spark_version" : {
      "type" : "fixed",
      "value" : "latest"
    },
    "node_type_id" : {
      "type" : "fixed",
      "value" : "Standard_DS3_v2"
    },
    "autotermination_minutes" : {
      "type" : "fixed",
      "value" : 30
    }
  })
}

# 2. Secret scope apontando para Key Vault
resource "databricks_secret_scope" "kv_scope" {
  provider = databricks.workspace
  name     = "kv-datamastermdl1"

  backend_type = "AZURE_KEYVAULT"

  keyvault_metadata {
    resource_id = "/subscriptions/<SUB_ID>/resourceGroups/<RG_NAME>/providers/Microsoft.KeyVault/vaults/kv-secret-datamastermdl1"
    dns_name    = var.keyvault_dns
  }
}

# 3. Ativar Unity Catalog
resource "databricks_metastore" "unity" {
  provider = databricks.workspace
  name     = "main-metastore"
  storage_root = "abfss://metastore@<STORAGE_ACCOUNT>.dfs.core.windows.net/"
}

resource "databricks_metastore_assignment" "assign" {
  provider     = databricks.workspace
  workspace_id = "<WORKSPACE_ID>"
  metastore_id = databricks_metastore.unity.id
  default_catalog_name = "finance"
}

# 4. Criar catalog e schemas
resource "databricks_catalog" "finance" {
  provider = databricks.workspace
  name     = "finance"
  comment  = "Catálogo financeiro"
}

resource "databricks_schema" "b_fin" {
  provider   = databricks.workspace
  name       = "b_fin"
  catalog_name = databricks_catalog.finance.name
}

resource "databricks_schema" "s_fin" {
  provider   = databricks.workspace
  name       = "s_fin"
  catalog_name = databricks_catalog.finance.name
}

