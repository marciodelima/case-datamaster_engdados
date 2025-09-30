variable "location" { default = "brazilsouth" }
variable "resource_group_name" { default = "rsg-datamaster" }
variable "spn_name" { default = "github-deploy-spn" }
variable "keyvault_name" { default = "kv-secret-datamastermdl2" }
variable "keyvault_rg" { default = "rsg-datamaster" }
variable "nome_storage" { default = "datamasterstore2025" }

variable "db_password" { default = "admin" }
variable "admin_email" { default = "marcio.lima.f1rst.2025@gmail.com" }
variable "github_repo" { default = "marciodelima/case-datamaster_engdados" }

variable "databricks_name" {
  default = "finance-databricks"
}

variable "eventhub_name" {
  default = "finance-events"
}

variable "log_name" {
  default = "finance-logs"
}


