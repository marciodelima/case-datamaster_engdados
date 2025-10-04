variable "databricks_connector_id" {}

variable "databricks_resource" {
  default = "2ff814a6-3304-4ab8-85cb-cd0e6f879c1d"
}

variable "spn_object_id" {}

variable "databricks_workspace_url" {
  type = string
}

variable "admin_email" {
  type = string
}

variable "keyvault_name" {
  type = string
}

variable "keyvault_resource_id" {
  type = string
}

variable "keyvault_dns" {
  type = string
}

variable "github_repo" {}

variable "storage_name" {}

variable "location" {}

variable "workspace_id" {}

variable "resource_group_name" {}
