output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "azure_client_id" {
  value = azuread_application.github_app.application_id
}

output "azure_client_secret" {
  value     = azuread_application_password.github_secret.value
  sensitive = true
}

output "azure_tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "azure_credentials_json" {
  value = jsonencode({
    clientId       = azuread_application.github_app.application_id
    clientSecret   = azuread_application_password.github_secret.value
    tenantId       = data.azurerm_client_config.current.tenant_id
    subscriptionId = data.azurerm_subscription.primary.subscription_id
  })
  sensitive = true
}

