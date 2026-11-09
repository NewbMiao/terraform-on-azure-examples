locals {
  shared_access_assignments = merge([
    for shared_key, shared in var.shared_resource_access : {
      for team_key in shared.teams :
      "${shared_key}:${team_key}" => {
        shared_key          = shared_key
        team_key            = team_key
        subscription_key    = shared.subscription_key
        resource_group_name = shared.resource_group_name
        resource_name       = shared.resource_name
        resource_type       = shared.resource_type
        roles               = shared.roles
        principal           = var.teams[team_key].security_group.display_name
      }
    }
  ]...)
}

locals {
  shared_access_assignments_prod = {
    for k, row in local.shared_access_assignments : k => row
    if row.subscription_key == "prod"
  }
}

resource "terraform_data" "shared_resource_access_assignment_prod" {
  for_each = local.shared_access_assignments_prod

  input = merge(each.value, {
    provider_alias = local.provider_alias_by_subscription_key[each.value.subscription_key]
  })
}
