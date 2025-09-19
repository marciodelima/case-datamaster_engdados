resource "azurerm_virtual_network" "vnet" {
  name                = "aks-vnet"
  location            = var.location
  resource_group_name = var.resource_group
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "aks_nsg" {
  name                = "aks-nsg"
  location            = var.location
  resource_group_name = var.resource_group

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTPS-Outbound"
    priority                   = 120
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-DNS-Outbound"
    priority                   = 130
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "53"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "aks_nsg_assoc" {
  subnet_id                 = azurerm_subnet.aks_subnet.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}

resource "azurerm_nat_gateway" "nat" {
  name                     = "aks-nat"
  location                 = var.location
  resource_group_name      = var.resource_group
  sku_name                 = "Standard"
  idle_timeout_in_minutes = 10
}

resource "azurerm_nat_gateway_public_ip_association" "nat_ip_assoc" {
  nat_gateway_id       = azurerm_nat_gateway.nat.id
  public_ip_address_id = azurerm_public_ip.nginx_ip.id
}

resource "azurerm_subnet_nat_gateway_association" "nat_assoc" {
  subnet_id      = azurerm_subnet.aks_subnet.id
  nat_gateway_id = azurerm_nat_gateway.nat.id
}

resource "azurerm_route_table" "aks_rt" {
  name                = "aks-route-table"
  location            = var.location
  resource_group_name = var.resource_group
}

resource "azurerm_subnet_route_table_association" "aks_rt_assoc" {
  subnet_id      = azurerm_subnet.aks_subnet.id
  route_table_id = azurerm_route_table.aks_rt.id
}

resource "azurerm_private_dns_zone" "internal_dns" {
  name                = "datamaster.internal"
  resource_group_name = var.resource_group
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_link" {
  name                  = "dns-link"
  resource_group_name   = var.resource_group
  private_dns_zone_name = azurerm_private_dns_zone.internal_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
}

resource "azurerm_private_dns_a_record" "namespace_dns_records" {
  for_each            = toset(var.namespaces)
  name                = each.key
  zone_name           = azurerm_private_dns_zone.internal_dns.name
  resource_group_name = var.resource_group
  ttl                 = 300
  records             = [azurerm_public_ip.nginx_ip.ip_address]
}

