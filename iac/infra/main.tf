terraform {
  required_version = ">= 1.3.0"
  
  backend "azurerm" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.0.0"
    }

    azapi = {
      source  = "azure/azapi"
      version = ">= 2.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "kubernetes" {
  host                   = module.aks.kube_config[0].host
  client_certificate     = base64decode(module.aks.kube_config[0].client_certificate)
  client_key             = base64decode(module.aks.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(module.aks.kube_config[0].cluster_ca_certificate)

  alias = "aks"
}

provider "azuread" {}

provider "azapi" {}

module "aks" {
  source = "./modules/aks"
}

