resource "azurerm_dns_zone" "public_dns" {
  name                = "marcio_datamaster.com"
  resource_group_name = var.resource_group
}

resource "azurerm_dns_a_record" "nginx_entry" {
  name                = "www"
  zone_name           = azurerm_dns_zone.public_dns.name
  resource_group_name = var.resource_group
  ttl                 = 300
  records             = [azurerm_public_ip.nginx_ingress_ip.ip_address]
}

