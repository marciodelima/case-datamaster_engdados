variable "location" { default = "brazilsouth" }
variable "resource_group_name" { default = "rsg-datamaster" }
variable "spn_name" { default = "github-deploy-spn" }
variable "keyvault_name" { default = "kv-secrets-datamastermdl" }
variable "keyvault_rg" { default = "rsg-datamaster" }

variable "tags" {
  description = "Tags padrão"
  type        = map(string)
  default = {
    project     = "datamaster"
    environment = "production"
    owner       = "marcio"
  }
}

variable "folders" {
  default = ["raw", "bronze", "silver", "gold", "stage"]
}

variable "location" {
  default = "East US"
}

variable "fabric_name" {
  default = "fabric-finance"
}

variable "databricks_name" {
  default = "databricks-finance"
}

variable "eventhub_name" {
  default = "finance-events"
}

variable "log_name" {
  default = "finance-logs"
}


