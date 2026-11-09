locals {
  prod_assignments = merge([
    for team_key, team in var.teams : merge([
      for rg_key, row in team.prod_resource_groups : {
        for role in row.roles :
        "${team_key}:prod:${rg_key}:${role}" => {
          team_key           = team_key
          environment        = "prod"
          subscription_key   = row.subscription_key
          resource_group_key = rg_key
          role               = role
          principal          = team.security_group.display_name
        }
      }
    ]...)
  ]...)

  dev_assignments = merge([
    for team_key, team in var.teams : merge([
      for rg_key, row in team.dev_resource_groups : {
        for role in row.roles :
        "${team_key}:dev:${rg_key}:${role}" => {
          team_key           = team_key
          environment        = "dev"
          subscription_key   = row.subscription_key
          resource_group_key = rg_key
          role               = role
          principal          = team.security_group.display_name
        }
      }
    ]...)
  ]...)

  team_rg_role_assignments = merge(local.prod_assignments, local.dev_assignments)

  team_rg_role_assignments_dev = {
    for k, row in local.team_rg_role_assignments : k => row
    if row.subscription_key == "dev"
  }

  team_rg_role_assignments_prod = {
    for k, row in local.team_rg_role_assignments : k => row
    if row.subscription_key == "prod"
  }

  role_keys_by_team = {
    for team_key in local.team_keys :
    team_key => {
      prod = sort([
        for k, row in local.prod_assignments :
        k if row.team_key == team_key
      ])
      dev = sort([
        for k, row in local.dev_assignments :
        k if row.team_key == team_key
      ])
    }
  }
}

resource "terraform_data" "role_assignment_dev" {
  for_each = local.team_rg_role_assignments_dev

  input = merge(each.value, {
    provider_alias = local.provider_alias_by_subscription_key[each.value.subscription_key]
  })
}

resource "terraform_data" "role_assignment_prod" {
  for_each = local.team_rg_role_assignments_prod

  input = merge(each.value, {
    provider_alias = local.provider_alias_by_subscription_key[each.value.subscription_key]
  })
}
