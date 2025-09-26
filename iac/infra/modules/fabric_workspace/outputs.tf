output "resource_group_name" {
  description = "Grupo de recursos do workspace Fabric"
  value       = azurerm_resource_group.fabric_rg.name
}

output "fabric_workspace_id" {
  description = "ID do Fabric Workspace"
  value       = data.external.fabric_identity.result["id"]
}

output "workspace_name" {
  description = "Nome do Fabric Workspace"
  value       = var.name
}

output "principal_id" {
  description = "Managed Identity principal ID do Fabric Workspace"
  value       = data.external.fabric_identity.result["principal_id"]
}

output "location" {
  description = "Localização do Fabric Workspace"
  value       = var.location
}

