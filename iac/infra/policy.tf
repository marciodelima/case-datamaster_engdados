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

data "azurerm_subscription" "primary" {}

resource "azurerm_subscription_policy_assignment" "deny_public_ip_assignment" {
  name                 = "deny-public-ip-assignment"
  display_name         = "Deny Public IP Assignment"
  policy_definition_id = azurerm_policy_definition.deny_public_ip_except_tagged.id
  subscription_id      = "/subscriptions/${data.azurerm_subscription.primary.subscription_id}"
}


