output "admin_user_id" {
  value = databricks_user.admin_user.id
}

output "admin_token_value" {
  value     = databricks_token.admin_token.token_value
  sensitive = true
}

