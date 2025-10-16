variable "location" {}
variable "resource_group_name" {}
variable "nome_storage" {}
variable "nome_topic" { default = "noticias_investimentos" }

variable "tags" {
  description = "Tags padrão"
  type        = map(string)
  default = {
    project     = "datamaster"
    environment = "production"
    owner       = "marcio"
  }
}

