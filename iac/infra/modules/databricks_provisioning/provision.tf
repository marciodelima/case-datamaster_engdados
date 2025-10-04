resource "null_resource" "provision_databricks" {
  provisioner "local-exec" {
    command = "bash ${path.module}/provision-databricks.sh"

    environment = {
      WORKSPACE_URL              = var.databricks_workspace_url
      ADMIN_EMAIL                = var.admin_email
      KEYVAULT_NAME              = var.keyvault_name
      KEYVAULT_RESOURCE_ID       = var.keyvault_resource_id
      KEYVAULT_DNS               = var.keyvault_dns
      GITHUB_REPO                = var.github_repo
      STORAGE_NAME               = var.storage_name
      ACCESS_CONNECTOR_ID        = var.databricks_connector_id
      DATABRICKS_RESOURCE        = var.databricks_resource
      METASTORE_NAME             = "meta-prd"
      REGION                     = var.location
      WORKSPACE_ID               = var.workspace_id
      SPN_OBJECT_ID              = var.spn_object_id
      DATABRICKS_RESOURCE_APP_ID = "a4ae5b76-5c63-4d36-bf27-3b3f9f5c4b4f"
    }
  }

  triggers = {
    always_run = timestamp()
  }
}

