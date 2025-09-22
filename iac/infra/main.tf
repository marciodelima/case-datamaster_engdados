provider "azurerm" {
  features {}
}

module "fabric" {
  source = "./modules/fabric_workspace"
  name   = var.fabric_name
  location = var.location
}

module "databricks" {
  source = "./modules/databricks_workspace"
  name   = var.databricks_name
  location = var.location
}

module "storage" {
  source = "./modules/storage"
  location = var.location
}

module "event_hubs" {
  source = "./modules/event_hubs"
  name   = var.eventhub_name
}

module "purview" {
  source = "./modules/purview"
  name   = var.purview_name
}

module "log_analytics" {
  source = "./modules/log_analytics"
  name   = var.log_name
}

