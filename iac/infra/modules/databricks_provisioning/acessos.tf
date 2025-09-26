data "databricks_group" "admins" {
  provider     = databricks.workspace
  display_name = "admins"
}

resource "databricks_user" "admin_user" {
  provider         = databricks.workspace
  user_name        = var.admin_email
  workspace_access = true
}

resource "databricks_group_member" "admin_assignment" {
  provider  = databricks.workspace
  group_id  = data.databricks_group.admins.id
  member_id = databricks_user.admin_user.id
}

resource "databricks_token" "admin_token" {
  provider         = databricks.workspace
  comment          = "Token pessoal para ${var.admin_email}"
  lifetime_seconds = 1209600
}

resource "null_resource" "store_token_in_github" {
  provisioner "local-exec" {
    command = "gh secret set DATABRICKS_ADMIN_TOKEN --body \"$TOKEN\" --repo \"$REPO\""

    environment = {
      TOKEN = databricks_token.admin_token.token_value
      REPO  = var.github_repo
    }
  }

  triggers = {
    token = databricks_token.admin_token.token_value
  }
}

