variable "location" { default = "brazilsouth" }
variable "resource_group" { default = "rsg-datamaster" }
variable "spn_name" { default = "github-deploy-spn" }
variable "keyvault_name" { default = "kv-secrets-datamastermdl" }
variable "keyvault_rg" { default = "rsg-datamaster" }

variable "namespaces" {
  type    = list(string)
  default = ["airflow", "kibana", "grafana", "prometheus", "app", "spark-history", "dashboard"]
}

variable "tags" {
  description = "Tags padrão"
  type        = map(string)
  default = {
    project     = "datamaster"
    environment = "production"
    owner       = "marcio"
  }
}

variable "admin_group_object_ids" {
  type    = list(string)
  default = []
}


