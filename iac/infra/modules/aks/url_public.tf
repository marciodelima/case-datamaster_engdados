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

resource "azurerm_web_application_firewall_policy" "waf_policy" {
  name                = "appgw-waf-policy"
  location            = var.location
  resource_group_name = var.resource_group

  custom_rules {
    name      = "BlockBadBots"
    priority  = 1
    rule_type = "MatchRule"
    action    = "Block"

    match_conditions {
      match_variables {
        variable_name = "RequestHeaders"
        selector      = "User-Agent"
      }
      operator           = "Contains"
      match_values       = ["BadBot"]
      negation_condition = false
      transforms         = ["Lowercase"]
    }
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
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
  
  firewall_policy_id = azurerm_web_application_firewall_policy.waf_policy.id
  
  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = azurerm_subnet.aks_subnet.id
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
    data     = filebase64("${path.module}/certificado.pfx")
    password = var.cert_password
  }

  http_listener {
    name                           = "https-listener"
    frontend_ip_configuration_name = "public-ip"
    frontend_port_name             = "https-port"
    ssl_certificate_name           = "ssl-cert"
    protocol                       = "Https"
  }

  request_routing_rule {
    name               = "default-routing"
    rule_type          = "PathBasedRouting"
    http_listener_name = "https-listener"
    url_path_map_name  = "path-routing"
    priority           = 100
  }

  url_path_map {
    name                               = "path-routing"
    default_backend_address_pool_name  = "default-pool"
    default_backend_http_settings_name = "default-settings"

    path_rule {
      name                       = "airflow-rule"
      paths                      = ["/airflow/*"]
      backend_address_pool_name  = "airflow-pool"
      backend_http_settings_name = "airflow-settings"
    }

    path_rule {
      name                       = "grafana-rule"
      paths                      = ["/grafana/*"]
      backend_address_pool_name  = "grafana-pool"
      backend_http_settings_name = "grafana-settings"
    }

    path_rule {
      name                       = "prometheus-rule"
      paths                      = ["/prometheus/*"]
      backend_address_pool_name  = "prometheus-pool"
      backend_http_settings_name = "prometheus-settings"
    }

    path_rule {
      name                       = "kibana-rule"
      paths                      = ["/kibana/*"]
      backend_address_pool_name  = "kibana-pool"
      backend_http_settings_name = "kibana-settings"
    }

    path_rule {
      name                       = "spark-rule"
      paths                      = ["/spark-history/*"]
      backend_address_pool_name  = "spark-history-pool"
      backend_http_settings_name = "spark-history-settings"
    }
  }

  backend_address_pool {
    name  = "airflow-pool"
    fqdns = ["airflow.privatedns.datamaster"]
  }

  backend_address_pool {
    name  = "grafana-pool"
    fqdns = ["grafana.privatedns.datamaster"]
  }

  backend_address_pool {
    name  = "prometheus-pool"
    fqdns = ["prometheus.privatedns.datamaster"]
  }

  backend_address_pool {
    name  = "kibana-pool"
    fqdns = ["kibana.privatedns.datamaster"]
  }

  backend_address_pool {
    name  = "default-pool"
    fqdns = ["default.privatedns.datamaster"]
  }

  backend_address_pool {
    name  = "spark-history-pool"
    fqdns = ["spark-history.privatedns.datamaster"]
  }

  backend_http_settings {
    name                                = "airflow-settings"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 30
    cookie_based_affinity               = "Disabled"
    pick_host_name_from_backend_address = true
  }

  backend_http_settings {
    name                                = "grafana-settings"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 30
    cookie_based_affinity               = "Disabled"
    pick_host_name_from_backend_address = true
  }

  backend_http_settings {
    name                                = "prometheus-settings"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 30
    cookie_based_affinity               = "Disabled"
    pick_host_name_from_backend_address = true
  }

  backend_http_settings {
    name                                = "kibana-settings"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 30
    cookie_based_affinity               = "Disabled"
    pick_host_name_from_backend_address = true
  }

  backend_http_settings {
    name                                = "spark-history-settings"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 30
    cookie_based_affinity               = "Disabled"
    pick_host_name_from_backend_address = true
  }

  backend_http_settings {
    name                                = "default-settings"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 30
    cookie_based_affinity               = "Disabled"
    pick_host_name_from_backend_address = true
  }
  
  depends_on          = [azurerm_public_ip.appgw_ip, azurerm_private_dns_zone.datamaster_dns, azurerm_dns_a_record.dataplatform]
}

