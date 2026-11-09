terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# One provider alias per subscription_key (fictional subscription IDs).
# The provider_alias tells you which subscription a deny lands in.
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
