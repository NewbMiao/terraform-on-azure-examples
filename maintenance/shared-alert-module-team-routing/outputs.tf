output "team_action_group_names" {
  description = "Action group names expanded from the platform team catalog."
  value       = { for k, ag in terraform_data.team_action_group : k => ag.input.name }
}

output "alert_scope_by_data_plane" {
  description = "Two tables, two scopes — layer-by-layer comparison with the lesson's Approach §4."
  value       = local.aca_scope_by_data_plane
}

output "alert_catalog_by_tier" {
  description = "Switches and thresholds for the six rule classes per tier (including disabled entries)."
  value       = local.aca_alert_catalog_by_tier
}

output "enabled_alert_rules" {
  description = "Only the enabled = true rules, matching the resources in alerts_*.tf."
  value = merge(
    { for k, r in terraform_data.aca_alert_job_startup : k => r.input },
    { for k, r in terraform_data.aca_alert_app_startup : k => r.input },
    { for k, r in terraform_data.aca_alert_app_restart : k => r.input },
    { for k, r in terraform_data.aca_alert_app_memory_high : k => r.input },
    { for k, r in terraform_data.aca_alert_app_cpu_high : k => r.input },
    { for k, r in terraform_data.aca_alert_pg_restart : k => r.input },
  )
}

output "relay_prod_startup_thresholds" {
  description = "prod startup threshold 0 (alert on a single match)."
  value = {
    job = local.aca_tiers["relay-prod"].rules.job_startup_failure.threshold
    app = local.aca_tiers["relay-prod"].rules.app_startup_failure.threshold
  }
}

output "relay_nonprod_app_startup_threshold" {
  description = "nonprod app startup threshold 1 (tolerates a single cold start)."
  value       = local.aca_tiers["relay-nonprod"].rules.app_startup_failure.threshold
}
