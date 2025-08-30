terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.0.0"
    }
  }
}

module "aks" {
  source = "./modules/aks"
}

provider "azurerm" {
  features {}
}

provider "azuread" {
}


