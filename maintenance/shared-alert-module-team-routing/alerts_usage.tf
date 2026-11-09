# Plays azurerm_monitor_scheduled_query_rules_alert_v2 — usage (AzureMetrics in the org LGW)
resource "terraform_data" "aca_alert_app_memory_high" {
  for_each = {
    for k, v in local.aca_alert_rule_matrix : k => v
    if v.rule_key == "app_memory_high"
  }

  input = merge(local.aca_alert_input_common[each.key], {
    rule_key          = "app_memory_high"
    data_plane        = "azure_metrics"
    metric_name       = "MemoryPercentage"
    description       = "Memory usage persistently high"
    threshold_percent = each.value.rule.threshold_percent
    window_minutes    = each.value.rule.window_minutes
    aggregation       = each.value.rule.aggregation
    query             = local.aca_kql_for_alert[each.key]
  })
}

resource "terraform_data" "aca_alert_app_cpu_high" {
  for_each = {
    for k, v in local.aca_alert_rule_matrix : k => v
    if v.rule_key == "app_cpu_high"
  }

  input = merge(local.aca_alert_input_common[each.key], {
    rule_key          = "app_cpu_high"
    data_plane        = "azure_metrics"
    metric_name       = "CpuPercentage"
    description       = "CPU usage peaks high"
    threshold_percent = each.value.rule.threshold_percent
    window_minutes    = each.value.rule.window_minutes
    aggregation       = each.value.rule.aggregation
    query             = local.aca_kql_for_alert[each.key]
  })
}
