output "active_deny_keys" {
  description = "Denies actually landing in the current phase; phase 3 should show only the three prod entries"
  value       = sort(keys(local.active_denies))
}

output "pending_deny_keys" {
  description = "Registered but not yet opened denies; they move to active once phase 4 is added to active_phases"
  value       = sort(keys(local.pending_denies))
}

output "rg_name_mismatches" {
  description = "Deny entries whose target is not in the team RG registry; should be empty"
  value       = local.rg_name_mismatches
}

output "deny_scope_check" {
  value = {
    for k, row in local.active_denies :
    k => "${row.deny_assignment_name} -> ${row.resource_group_name} (${local.provider_alias_by_subscription_key[row.subscription_key]})"
  }
}
