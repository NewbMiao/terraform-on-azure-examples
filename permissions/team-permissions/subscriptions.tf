locals {
  provider_alias_by_subscription_key = {
    dev  = "azurerm.dev"
    prod = "azurerm.prod"
  }

  subscription_keys_used = toset(flatten(concat(
    [
      for team_key, team in var.teams : concat(
        [for _, row in team.prod_resource_groups : row.subscription_key],
        [for _, row in team.dev_resource_groups : row.subscription_key],
        [for _, row in team.resource_access : row.subscription_key],
      )
    ],
    [for _, shared in var.shared_resource_access : shared.subscription_key],
  )))
}

resource "terraform_data" "subscription_entry" {
  for_each = var.subscriptions

  input = {
    subscription_key = each.key
    subscription_id  = each.value.subscription_id
    display_name     = each.value.display_name
    purpose          = each.value.purpose
    provider_alias   = local.provider_alias_by_subscription_key[each.key]
    used_by_teams    = local.team_keys
  }
}
