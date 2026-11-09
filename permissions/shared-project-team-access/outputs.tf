output "team_entra_entitlement_link" {
  value = {
    for team_key, team in var.teams :
    team_key => {
      sgrp      = team.security_group.display_name
      object_id = team.security_group.object_id
      ado_group = local.ado_team_display_name[team_key]
    }
  }
}

output "team_sc_allow_list" {
  value = local.team_sc_allow_list
}

output "team_sc_name_mismatches" {
  description = "Should be non-empty when another team's SC name sneaks into the allowlist"
  value       = sort(local.team_sc_name_mismatches)
}

output "service_connection_scope_check" {
  value = {
    for k, row in local.team_service_connections :
    k => "${row.name} -> ${row.scope_rg}"
  }
}

output "deploy_rbac_roles_per_connection" {
  value = {
    for sc_key, sc in local.team_service_connections :
    sc_key => ["Contributor", "Key Vault Secrets User"]
  }
}

output "kv_variable_group_catalog" {
  value = sort(keys(local.kv_variable_groups))
}

output "library_variable_groups" {
  value = sort(keys(local.library_variable_group_grants))
}

output "library_environments" {
  value = sort(keys(local.library_environment_grants))
}

output "cross_team_kv_admin" {
  description = "Should be non-empty if a KV-linked VG grants Administrator to a non-owner team"
  value = sort([
    for k, row in local.library_variable_group_grants :
    k
    if row.key_vault != null
    && row.role_name == "Administrator"
    && row.team_key != local.kv_variable_groups[row.variable_group].owner
  ])
}

output "acr_scope_token_paths" {
  value = {
    for k, row in local.acr_scope_token_assignments :
    k => "${row.registry_name}:${row.path}"
  }
}

output "legacy_subscription_service_connections" {
  description = "For contrast — the dev/prd subscription-scoped SC names shared by the whole project before the switch"
  value = {
    for k, cfg in var.legacy_subscription_service_connections :
    k => cfg.name
  }
}

output "git_repository_grants" {
  value = {
    for k, row in local.team_repository_grants :
    k => row.repository_name
  }
}

output "git_repository_cross_team_denies" {
  description = "Number of Deny entries other teams' groups get on this repo when deny_other_teams is true"
  value       = length(local.team_repository_other_team_denies)
}
