terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# One azurerm alias per subscription_key (RBAC is granted per dev / prod table).
# deploy_rbac_assignment and the team service connections align their subscription_label from here.
provider "azurerm" {
  alias                           = "dev"
  subscription_id                 = var.subscriptions["dev"].subscription_id
  resource_provider_registrations = "none"
  features {}
}

provider "azurerm" {
  alias                           = "prod"
  subscription_id                 = var.subscriptions["prod"].subscription_id
  resource_provider_registrations = "none"
  features {}
}
