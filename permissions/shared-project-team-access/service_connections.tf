# After the switch: one ARM connection (WIF) per team per environment, scope = the team's own RG. Contrast in legacy_shared_service_connections.tf

locals {
  team_service_connections = merge([
    for team_key, team in var.teams : {
      for env_key, rg in team.resource_groups :
      "${team_key}:${env_key}" => {
        team_key         = team_key
        environment      = env_key
        name             = "sc-${team_key}-${env_key}"
        identity         = "wi-${team_key}-deploy"
        subscription_key = rg.subscription_key
        scope_rg         = rg.name
        scope_kind       = "resource_group"
      }
    }
  ]...)
}

resource "terraform_data" "team_service_connection" {
  for_each = local.team_service_connections

  input = merge(each.value, {
    azure_resource     = "azuredevops_serviceendpoint_azurerm"
    auth_scheme        = "WorkloadIdentityFederation"
    provider_alias     = local.provider_alias_by_subscription_key[each.value.subscription_key]
    subscription_label = var.subscriptions[each.value.subscription_key].display_name
  })
}
