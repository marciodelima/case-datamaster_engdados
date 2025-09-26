terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "databricks" {
  alias = "workspace"
  host  = module.databricks.workspace_url
  token = var.bootstrap_token
}

terraform {
  backend "azurerm" {}
}

module "fabric" {
  source                     = "./modules/fabric_workspace"
  name                       = var.fabric_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id
}

module "databricks" {
  source              = "./modules/databricks_workspace"
  name                = var.databricks_name
  location            = var.location
  resource_group_name = var.resource_group_name
}

module "databricks_provisioning" {
  source = "./modules/databricks_provisioning"

  providers = {
    databricks = databricks.workspace
  }

  databricks_workspace_url = module.databricks.workspace_url
  admin_email              = var.admin_email
}

module "storage" {
  source              = "./modules/storage"
  location            = var.location
  resource_group_name = var.resource_group_name
}

module "event_hubs" {
  source              = "./modules/event_hubs"
  location            = var.location
  resource_group_name = var.resource_group_name
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
}

module "openai" {
  source              = "./modules/openai"
  resource_group_name = var.resource_group_name
  location            = var.location
}

module "function" {
  source              = "./modules/azure_functions"
  resource_group_name = var.resource_group_name
  location            = var.location
}

module "dashboard" {
  source              = "./modules/dashboard"
  resource_group_name = var.resource_group_name
  location            = var.location
  databricks_id       = module.databricks.workspace_id
  storage_id          = module.storage.storage_id
  eventhub_id         = module.event_hubs.eventhub_namespace_id
}

module "alerts" {
  source              = "./modules/alerts"
  resource_group_name = var.resource_group_name
  location            = var.location
  databricks_wk_id    = module.databricks.workspace_id
}

