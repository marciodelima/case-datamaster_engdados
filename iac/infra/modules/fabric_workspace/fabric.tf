resource "azurerm_resource_group" "fabric_rg" {
  name     = var.name
  location = var.location
}

resource "null_resource" "create_fabric_workspace" {
  provisioner "local-exec" {
    command = <<EOT
      az extension add --name microsoft-fabric || echo "Fabric extension already installed"

      az fabric capacity create \
        --resource-group ${var.resource_group_name} \
        --capacity-name ${var.name} \
        --sku "{name:F2,tier:Fabric}" \
	--administration "{members:['${var.admin_email}']}"
        --location ${var.location} \
        --tags "{environment:prod}"
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
  --logs '[{"category": "Audit", "enabled": true}, {"category": "Jobs", "enabled": true}]' \
  --metrics '[{"category": "AllMetrics", "enabled": true}]'
EOT
  }
}

