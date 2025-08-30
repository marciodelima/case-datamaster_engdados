variable "location" { default = "brazilsouth" }
variable "resource_group_name" {  default = "rsg-datamaster" }
variable "spn_name"       { default = "github-deploy-spn" }
variable "keyvault_name"  { default = "kv-iac-secrets" }
variable "keyvault_rg"    { default = "rsg-datamaster" }

variable "tags" {
  description = "Tags padrão"
  type        = map(string)
  default     = {
    environment = "production"
    owner       = "marcio"
  }
}
