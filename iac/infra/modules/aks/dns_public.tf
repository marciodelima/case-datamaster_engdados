resource "azurerm_dns_zone" "dns" {
  name                = "marcio_datamaster.com.br"
  resource_group_name = var.resource_group
}

resource "azurerm_dns_a_record" "dataplatform" {
  name                = "dataplatform"
  zone_name           = azurerm_dns_zone.dns.name
  resource_group_name = var.resource_group
  ttl                 = 300
  records             = [azurerm_public_ip.appgw_ip.id]
  depends_on          = [azurerm_public_ip.appgw_ip]
}


