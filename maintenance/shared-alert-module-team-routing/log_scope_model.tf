# Two tables, two KQL scopes — mirrors the shared aca_alerts module (the lesson's progressive comparison table)
locals {
  aca_scope_by_data_plane = {
    container_app_system_logs = {
      rules         = ["job_startup_failure", "app_startup_failure", "app_restart"]
      table         = "ContainerAppSystemLogs_CL"
      tier_input    = "aca_alerts.<tier>.resource_groups"
      kql_scope     = "EnvironmentName_s (managed env default_domain prefix) or ContainerAppName_s / JobName_s in (...)"
      not_on_table  = ["ResourceGroup", "_ResourceId is usually empty and can't filter RGs"]
      parent_stack  = "managed_env_log_names_by_rg (the example uses aca_environment_log_names)"
      portal_sanity = "| where EnvironmentName_s == \"relay-dev-sea\"  // sample env label; try the system-log scope in Logs"
    }
    azure_metrics = {
      rules         = ["app_memory_high", "app_cpu_high"]
      table         = "AzureMetrics"
      tier_input    = "aca_alerts.<tier>.resource_groups"
      kql_scope     = "ResourceGroup in ('RG-…') and _ResourceId has containerApps"
      not_on_table  = []
      parent_stack  = "Rule names split per ACA env; KQL still uses the tier's RG list"
      portal_sanity = "| where ResourceGroup == \"RG-RELAY-DEV-SEA\"  // sample tier RG; try it in AzureMetrics"
    }
    azure_diagnostics_pg = {
      rules         = ["pg_restart"]
      table         = "AzureDiagnostics"
      tier_input    = "aca_alerts.<tier>.resource_groups"
      kql_scope     = "ResourceGroup in~ ('RG-…')；Category PostgreSQLLogs"
      not_on_table  = []
      parent_stack  = "New PGs in the tier are covered automatically; diagnostics must already reach the org LGW"
      portal_sanity = "| where ResourceGroup == \"RG-RELAY-PRD-SEA\"  // try shutdown/ready rows in PostgreSQLLogs"
    }
  }
}
