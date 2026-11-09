# Plays azurerm_monitor_scheduled_query_rules_alert_v2 — repeated abnormal exits (ContainerAppSystemLogs_CL)
resource "terraform_data" "aca_alert_app_restart" {
  for_each = {
    for k, v in local.aca_alert_rule_matrix : k => v
    if v.rule_key == "app_restart"
  }

  input = merge(local.aca_alert_input_common[each.key], {
    rule_key       = "app_restart"
    data_plane     = "container_app_system_logs"
    description    = "Repeated abnormal exits within a short window"
    threshold      = each.value.rule.threshold
    window_minutes = each.value.rule.window_minutes
    query          = local.aca_kql_for_alert[each.key]
  })
}
