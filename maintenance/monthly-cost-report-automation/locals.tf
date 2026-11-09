locals {
  report  = var.automation.monthly_cost_report
  enabled = var.automation.enabled && try(local.report.enabled, false)

  automation_principal_id = local.enabled ? terraform_data.automation_account[0].input.identity_principal_id : null

  schedule_start_time = local.enabled ? format(
    "%s-%02dT%02d:%02d:00+08:00",
    formatdate("YYYY-MM", timeadd(timestamp(), "744h")),
    local.report.schedule.day_of_month,
    local.report.schedule.hour,
    coalesce(try(local.report.schedule.minute, null), 0),
  ) : null

  workload_scopes = local.enabled ? flatten([
    for env_key, row in local.report.resource_groups : [
      for rg, item in row.items : {
        subscription_id = var.subscriptions[row.subscription_key].subscription_id
        resource_group  = rg
        env_label       = env_key
        team_label      = item.team
      }
    ]
  ]) : []

  report_config_json = local.enabled ? jsonencode({
    cost_type         = "ActualCost"
    diff_threshold    = coalesce(try(local.report.diff_threshold, null), 100)
    use_current_month = coalesce(try(local.report.use_current_month, null), false)
    scopes            = local.workload_scopes
    budget_pins       = try(local.report.budget_pins, {})
  }) : null

  budget_pins_json = local.enabled && length(try(local.report.budget_pins, {})) > 0 ? jsonencode(local.report.budget_pins) : null
}
