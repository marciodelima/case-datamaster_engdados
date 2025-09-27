terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.0.0"
    }
  }
}

provider "databricks" {
  alias = "workspace"
  host  = var.databricks_workspace_url
}
