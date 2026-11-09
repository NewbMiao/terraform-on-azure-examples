# Plays azurerm_monitor_scheduled_query_rules_alert_v2 — startup failures (ContainerAppSystemLogs_CL)
locals {
  aca_startup_alert_matrix = {
    for k, v in local.aca_alert_rule_matrix : k => v
    if contains(["job_startup_failure", "app_startup_failure"], v.rule_key)
  }
}

resource "terraform_data" "aca_alert_job_startup" {
  for_each = {
    for k, v in local.aca_startup_alert_matrix : k => v
    if v.rule_key == "job_startup_failure"
  }

  input = merge(local.aca_alert_input_common[each.key], {
    rule_key    = "job_startup_failure"
    data_plane  = "container_app_system_logs"
    description = "Job startup failed, backoff exhausted"
    threshold   = each.value.rule.threshold
    query       = local.aca_kql_for_alert[each.key]
  })
}

resource "terraform_data" "aca_alert_app_startup" {
  for_each = {
    for k, v in local.aca_startup_alert_matrix : k => v
    if v.rule_key == "app_startup_failure"
  }

  input = merge(local.aca_alert_input_common[each.key], {
    rule_key    = "app_startup_failure"
    data_plane  = "container_app_system_logs"
    description = "App image-pull failures, crash loops, probe or OOM kills"
    threshold   = each.value.rule.threshold
    query       = local.aca_kql_for_alert[each.key]
  })
}
