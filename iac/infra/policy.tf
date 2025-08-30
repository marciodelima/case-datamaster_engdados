resource "azurerm_policy_definition" "deny_public_ip" {
  name         = "deny-public-ip"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Deny Public IP"
  description  = "Bloqueia criação de IPs públicos"

  policy_rule = <<POLICY
{
  "if": {
    "field": "Microsoft.Network/publicIPAddresses/ipAddress",
    "exists": "true"
  },
  "then": {
    "effect": "deny"
  }
}
POLICY
}

resource "azurerm_policy_assignment" "deny_public_ip_assignment" {
  name                 = "deny-public-ip-assignment"
  scope                = data.azurerm_subscription.primary.id
  policy_definition_id = azurerm_policy_definition.deny_public_ip.id
}

resource "azurerm_policy_definition" "deny_public_ip_except_tagged" {
  name         = "deny-public-ip-except-tagged"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Deny Public IP Except Tagged"
  description  = "Bloqueia IPs públicos, exceto os com tag allow=appgw"

  policy_rule = <<POLICY
{
  "if": {
    "allOf": [
      {
        "field": "type",
        "equals": "Microsoft.Network/publicIPAddresses"
      },
      {
        "not": {
          "field": "tags.allow",
          "equals": "appgw"
        }
      }
    ]
  },
  "then": {
    "effect": "deny"
  }
}
POLICY
}

