resource "azurerm_resource_group" "fabric_rg" {
  name     = var.name
  location = var.location
}

resource "null_resource" "create_fabric_workspace" {
  provisioner "local-exec" {
    command = <<EOT
      az fabric workspace create \
        --name ${var.name} \
        --resource-group ${var.resource_group_name} \
        --location ${var.location} \
        --identity-type SystemAssigned \
        --tags environment=prod
    EOT
  }

  triggers = {
    workspace_name = var.name
  }
}

data "external" "fabric_identity" {
  program = ["bash", "${path.module}/get_fabric_identity.sh"]

  query = {
    name           = var.name
    resource_group = var.resource_group_name
  }

  depends_on = [null_resource.create_fabric_workspace]
}

resource "null_resource" "fabric_diag" {
  provisioner "local-exec" {
    command = <<EOT
az monitor diagnostic-settings create \
  --name "fabric-diagnostics" \
  --resource ${var.log_analytics_workspace_id} \
  --workspace ${var.log_analytics_workspace_id} \
  --logs '[{"category":"AllLogs","enabled":true}]' \
  --metrics '[{"category":"AllMetrics","enabled":true}]'
EOT
  }
}

