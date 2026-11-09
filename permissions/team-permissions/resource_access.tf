locals {
  resource_access_assignments = merge([
    for team_key, team in var.teams : {
      for access_key, row in team.resource_access :
      "${team_key}:access:${access_key}" => {
        team_key            = team_key
        subscription_key    = row.subscription_key
        resource_group_name = row.resource_group_name
        resource_name       = row.resource_name
        resource_type       = row.resource_type
        roles               = row.roles
        environments        = row.environments
        principal           = team.security_group.display_name
      }
    }
  ]...)
}

locals {
  resource_access_assignments_dev = {
    for k, row in local.resource_access_assignments : k => row
    if row.subscription_key == "dev"
  }

  resource_access_assignments_prod = {
    for k, row in local.resource_access_assignments : k => row
    if row.subscription_key == "prod"
  }
}

resource "terraform_data" "resource_access_assignment_dev" {
  for_each = local.resource_access_assignments_dev

  input = merge(each.value, {
    provider_alias = local.provider_alias_by_subscription_key[each.value.subscription_key]
  })
}

resource "terraform_data" "resource_access_assignment_prod" {
  for_each = local.resource_access_assignments_prod

  input = merge(each.value, {
    provider_alias = local.provider_alias_by_subscription_key[each.value.subscription_key]
  })
}
