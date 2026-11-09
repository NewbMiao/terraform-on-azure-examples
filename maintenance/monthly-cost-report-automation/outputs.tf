output "schedule_anchor" {
  description = "Monthly schedule anchor (future timestamp + ignore_changes on start_time)."
  value       = local.enabled ? local.schedule_start_time : null
}

output "workload_scope_count" {
  description = "Number of team RG rows after the config sheet is flattened."
  value       = length(local.workload_scopes)
}

output "cost_reader_subscription_ids" {
  description = "Subscriptions that have been granted Cost Management Reader."
  value = [
    for k, _ in terraform_data.cost_management_reader :
    var.subscriptions[k].subscription_id
  ]
}
