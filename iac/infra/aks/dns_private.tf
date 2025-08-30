resource "azurerm_private_dns_zone" "datamaster_dns" {
  name                = "privatedns.datamaster"
  resource_group_name = var.resource_group
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_link" {
  name                  = "datamaster-dns-link"
  resource_group_name   = var.resource_group
  private_dns_zone_name = azurerm_private_dns_zone.datamaster_dns.name
  virtual_network_id    = azurerm_virtual_network.aks_vnet.id
  registration_enabled  = true
}

