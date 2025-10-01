resource "null_resource" "provision_databricks" {
  provisioner "local-exec" {
    command = "bash ${path.module}/provision-databricks.sh"

    environment = {
      WORKSPACE_URL        = var.databricks_workspace_url
      ADMIN_EMAIL          = var.admin_email
      KEYVAULT_NAME        = var.keyvault_name
      KEYVAULT_RESOURCE_ID = var.keyvault_resource_id
      KEYVAULT_DNS         = var.keyvault_dns
      GITHUB_REPO          = var.github_repo
      STORAGE_NAME         = var.storage_name
      ACCESS_CONNECTOR_ID  = var.databricks_connector_id
    }
  }

  triggers = {
    always_run = timestamp()
  }
}

