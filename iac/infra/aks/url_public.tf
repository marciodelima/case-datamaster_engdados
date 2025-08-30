resource "azurerm_public_ip" "appgw_ip" {
  name                = "appgw-public-ip"
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    allow = "appgw"
  }
}

resource "azurerm_application_gateway" "appgw" {
  name                = "aks-appgw"
  location            = var.location
  resource_group_name = var.resource_group
  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  frontend_ip_configuration {
    name                 = "public-ip"
    public_ip_address_id = azurerm_public_ip.appgw_ip.id
  }

  frontend_port {
    name = "https-port"
    port = 443
  }

  ssl_certificate {
    name     = "ssl-cert"
    data     = filebase64(var.cert_path)
    password = var.cert_password
  }

  http_listener {
    name                           = "https-listener"
    frontend_ip_configuration_name = "public-ip"
    frontend_port_name             = "https-port"
    ssl_certificate_name           = "ssl-cert"
    protocol                       = "Https"
  }

  url_path_map {
    name                           = "path-routing"
    default_backend_address_pool_name = "default-pool"
    default_backend_http_settings_name = "default-settings"

    path_rule {
      name                       = "airflow-rule"
      paths                      = ["/airflow/*"]
      backend_address_pool_name = "airflow-pool"
      backend_http_settings_name = "airflow-settings"
    }

    path_rule {
      name                       = "grafana-rule"
      paths                      = ["/grafana/*"]
      backend_address_pool_name = "grafana-pool"
      backend_http_settings_name = "grafana-settings"
    }

    path_rule {
      name                       = "prometheus-rule"
      paths                      = ["/prometheus/*"]
      backend_address_pool_name = "prometheus-pool"
      backend_http_settings_name = "prometheus-settings"
    }
    path_rule {
      name                       = "kibana-rule"
      paths                      = ["/kibana/*"]
      backend_address_pool_name = "kibana-pool"
      backend_http_settings_name = "kibana-settings"
    }
  }

  backend_address_pool {
    name = "airflow-pool"
    backend_addresses {
      fqdn = "airflow.privatedns.datamaster"
    }
  }

  backend_address_pool {
    name = "grafana-pool"
    backend_addresses {
      fqdn = "grafana.privatedns.datamaster"
    }
  }

  backend_address_pool {
    name = "prometheus-pool"
    backend_addresses {
      fqdn = "prometheus.privatedns.datamaster"
    }
  }
  
  backend_address_pool {
    name = "kibana-pool"
    backend_addresses {
      fqdn = "kibana.privatedns.datamaster"
    }
  }

  backend_address_pool {
    name = "default-pool"
    backend_addresses {
      fqdn = "default.privatedns.datamaster"
    }
  }

  backend_http_settings {
    name                  = "airflow-settings"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 30
    pick_host_name_from_backend_address = true
  }

  backend_http_settings {
    name                  = "grafana-settings"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 30
    pick_host_name_from_backend_address = true
  }

  backend_http_settings {
    name                  = "prometheus-settings"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 30
    pick_host_name_from_backend_address = true
  }

  backend_http_settings {
    name                  = "kibana-settings"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 30
    pick_host_name_from_backend_address = true
  }

  backend_http_settings {
    name                  = "default-settings"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 30
    pick_host_name_from_backend_address = true
  }

}

