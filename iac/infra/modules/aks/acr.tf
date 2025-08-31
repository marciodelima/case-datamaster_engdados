data "azurerm_container_registry" "acr" {
  name                = "acrregistrydatamaster"
  resource_group_name = var.resource_group
}

