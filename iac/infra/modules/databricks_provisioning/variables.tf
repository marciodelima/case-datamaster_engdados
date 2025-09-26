variable "admin_email" {
  type        = string
}

variable "databricks_workspace_url" {
  type = string
}

variable "bootstrap_token" {
  type      = string
  sensitive = true
}

