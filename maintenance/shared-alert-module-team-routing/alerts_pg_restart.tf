# Plays azurerm_monitor_scheduled_query_rules_alert_v2 — PostgreSQL restarts (AzureDiagnostics / PostgreSQLLogs)
resource "terraform_data" "aca_alert_pg_restart" {
  for_each = {
    for k, v in local.aca_alert_rule_matrix : k => v
    if v.rule_key == "pg_restart"
  }

  input = merge(local.aca_alert_input_common[each.key], {
    rule_key       = "pg_restart"
    data_plane     = "azure_diagnostics_pg"
    description    = "Flexible Server stopped then ready again; any PG in the tier RG"
    window_minutes = each.value.rule.window_minutes
    query          = local.aca_kql_for_alert[each.key]
  })
}
