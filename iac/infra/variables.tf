variable "location" { default = "brazilsouth" }
variable "resource_group_name" {  default = "rsg-datamaster" }
variable "spn_name"       { default = "github-deploy-spn" }
variable "keyvault_name"  { default = "kv-iac-secrets" }
variable "keyvault_rg"    { default = "rsg-datamaster" }

variable "namespaces" {
  type    = list(string)
  default = ["airflow", "elk", "spark", "spark-operator", "grafana", "prometheus", "nginx"]
}

variable "cert_password"    { 
  type        = string
  sensitive   = true
  default = "12345678" 
}
variable "cert_path" { default = "certificado.pfx" }

variable "tags" {
  description = "Tags padrão"
  type        = map(string)
  default     = {
    environment = "production"
    owner       = "marcio"
  }
}
