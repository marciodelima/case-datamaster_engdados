variable "location" {}
variable "resource_group_name" {}
variable "nome_storage" {}

variable "tags" {
  description = "Tags padrão"
  type        = map(string)
  default = {
    project     = "datamaster"
    environment = "production"
    owner       = "marcio"
  }
}

