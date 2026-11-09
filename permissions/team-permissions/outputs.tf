output "team_sgrps" {
  value = {
    for k, team in var.teams :
    k => team.security_group.display_name
  }
}

output "role_assignment_keys" {
  value = local.role_keys_by_team
}

output "resource_access_keys" {
  value = sort(keys(local.resource_access_assignments))
}

output "shared_resource_access_keys" {
  value = sort(keys(local.shared_access_assignments))
}

output "subscription_keys_used" {
  value = sort(tolist(local.subscription_keys_used))
}
