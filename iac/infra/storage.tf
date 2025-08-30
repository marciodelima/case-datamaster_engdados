resource "azurerm_storage_account" "storage" {
  name                     = "datamasterstorage${random_id.suffix.hex}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "ZRS"
  is_hns_enabled           = true
  is_blob_access_tracking_enabled = true
  is_versioning_enabled           = true

  identity {
    type = "UserAssigned"
    user_assigned_identity = {
      "${azurerm_user_assigned_identity.integration_identity.id}" = azurerm_user_assigned_identity.integration_identity.id
    }
  }

  blob_properties {
    delete_retention_policy {
      days = 7
    }

    container_delete_retention_policy {
      days = 7
    }

    lifecycle {
      rule {
        name    = "delete_raw_after_2_days"
        enabled = true

        filter {
          prefix_match = ["dados/raw/"]
        }

        action {
          base_blob {
            delete_after_creation {
              days_after_creation_greater_than = 2
            }
          }
        }
      }

      rule {
        name    = "move_to_cool_after_7_days_no_access"
        enabled = true

        filter {
          prefix_match = ["dados/"]
        }

        action {
          base_blob {
            tier_to_cool {
              days_after_last_access_time_greater_than = 7
            }
          }
        }
      }

      rule {
        name    = "move_to_cold_after_30_days_no_access"
        enabled = true

        filter {
          prefix_match = ["dados/"]
        }

        action {
          base_blob {
            tier_to_archive {
              days_after_last_access_time_greater_than = 30
            }
          }
        }
      }
    }
  }
}

resource "azurerm_storage_container" "dados" {
  name                  = "dados"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

resource "azurerm_storage_data_lake_gen2_path" "folders" {
  count                 = length(["raw", "bronze", "silver", "gold"])
  path                  = "dados/${element(["raw", "bronze", "silver", "gold"], count.index)}"
  filesystem_name       = azurerm_storage_container.dados.name
  storage_account_name  = azurerm_storage_account.storage.name
  resource              = "directory"
}

