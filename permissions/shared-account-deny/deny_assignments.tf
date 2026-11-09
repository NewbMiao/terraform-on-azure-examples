locals {
  provider_alias_by_subscription_key = {
    dev  = "azurerm.dev"
    prod = "azurerm.prod"
  }

  # Denies opened by the current phase; entries outside active_phases stay in the table but do not land
  active_denies = {
    for k, row in var.deny_assignments : k => row
    if contains(var.active_phases, row.phase)
  }

  pending_denies = {
    for k, row in var.deny_assignments : k => row
    if !contains(var.active_phases, row.phase)
  }

  # Reverse lookup from the team RG registry: RG names registered under a subscription
  registered_rg_names_by_subscription = {
    for sub_key in ["dev", "prod"] : sub_key => toset(flatten([
      for team in var.team_resource_groups : [
        for rg in team.resource_groups : rg.name
        if rg.subscription_key == sub_key
      ]
    ]))
  }

  # Deny entries whose target is not in the team RG registry — should surface at plan time, not be discovered after apply in the wrong place
  rg_name_mismatches = {
    for k, row in var.deny_assignments : k => row.resource_group_name
    if !contains(local.registered_rg_names_by_subscription[row.subscription_key], row.resource_group_name)
  }
}

# In production this usually lands at RG scope via azapi; azurerm has no deny resource type
resource "terraform_data" "deny_assignment" {
  for_each = local.active_denies

  input = merge(each.value, {
    provider_alias = local.provider_alias_by_subscription_key[each.value.subscription_key]
    scope_kind     = "resource_group"
  })
}
