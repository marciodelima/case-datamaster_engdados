terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {}
}

module "databricks" {
  source              = "./modules/databricks_workspace"
  name                = var.databricks_name
  location            = var.location
  resource_group_name = var.resource_group_name
}

module "databricks_provisioning" {
  source = "./modules/databricks_provisioning"

  databricks_workspace_url = module.databricks.workspace_url
  admin_email              = var.admin_email
  keyvault_name            = var.keyvault_name
  keyvault_resource_id     = data.azurerm_key_vault.kv.id
  keyvault_dns             = data.azurerm_key_vault.kv.vault_uri
  github_repo              = var.github_repo
  storage_name             = var.nome_storage
  depends_on               = [module.databricks, module.storage]
}

module "storage" {
  source              = "./modules/storage"
  location            = var.location
  resource_group_name = var.resource_group_name
  nome_storage        = var.nome_storage
}

module "event_hubs" {
  source              = "./modules/event_hubs"
  location            = var.location
  resource_group_name = var.resource_group_name
  nome_storage        = module.storage.storage_name
  depends_on          = [module.storage]
}

module "purview" {
  source              = "./modules/purview"
  location            = var.location
  resource_group_name = var.resource_group_name
}

module "postgres" {
  source              = "./modules/postgres"
  resource_group_name = var.resource_group_name
  location            = var.location
  db_password         = var.db_password
  keyvault_name       = var.keyvault_name
}

module "openai" {
  source              = "./modules/openai"
  resource_group_name = var.resource_group_name
  location            = var.location
  keyvault_name       = var.keyvault_name
}

module "function" {
  source                             = "./modules/azure_functions"
  resource_group_name                = var.resource_group_name
  location                           = var.location
  existing_storage_account_name      = module.storage.storage_name
  keyvault_name                      = var.keyvault_name
  eventhub_namespace_name            = module.event_hubs.eventhub_namespace_name
  azurerm_log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id
  depends_on                         = [module.storage, module.event_hubs, azurerm_log_analytics_workspace.logs]
}

module "dashboard" {
  source              = "./modules/dashboard"
  resource_group_name = var.resource_group_name
  location            = var.location
  databricks_id       = module.databricks.workspace_id
  storage_id          = module.storage.storage_id
  eventhub_id         = module.event_hubs.eventhub_namespace_id
  depends_on          = [module.storage, module.event_hubs, module.databricks]
}

module "alerts" {
  source              = "./modules/alerts"
  resource_group_name = var.resource_group_name
  location            = var.location
  workspace_logs_id   = azurerm_log_analytics_workspace.logs.id
  email               = var.admin_email
  depends_on          = [azurerm_log_analytics_workspace.logs]
}


