# KQL mirrors the shared aca_alerts module. Startup/restart: ContainerAppSystemLogs_CL has no ResourceGroup column → see log_scope_model.tf
variable "aca_environment_log_names" {
  type        = map(list(string))
  description = "Per-tier EnvironmentName_s list. The system log table can't filter by RG; the parent stack derives it from the ACA env default_domain (same role as managed_env_log_names_by_rg)."
  default     = {}
}

locals {
  aca_kql_job_failure = <<-KQL
Reason_s in ("BackoffLimitExceeded", "DeadlineExceeded", "Failed")
or Log_s has_any ("Failed to pull", "ImagePullBackOff", "Persistent Image Pull", "CrashLoopBackOff", "OOMKilled")
KQL

  aca_kql_app_failure = <<-KQL
Reason_s in ("ImagePullBackOff", "CrashLoopBackOff", "OOMKilled", "ContainerBackOff", "Evicted", "Failed", "Error")
or Log_s has_any ("ImagePullBackOff", "CrashLoopBackOff", "Persistent Failure", "Failed to pull", "Persistent Image Pull")
or (Reason_s == "ContainerTerminated" and (Log_s has "exit code '137'" or Log_s has "ProbeFailure"))
KQL

  aca_kql_app_restart = <<-KQL
Reason_s in ("CrashLoopBackOff", "ContainerBackOff")
or (Reason_s == "ContainerTerminated" and Log_s has "exit code '137'")
KQL

  aca_kql_app_failure_reason = <<-KQL
| extend FailureReason = case(
    Reason_s == "ContainerTerminated" and Log_s has "ProbeFailure", "ContainerTerminated-ProbeFailure",
    Reason_s == "ContainerTerminated" and Log_s has "exit code '137'", "ContainerTerminated-OOM",
    Reason_s
  )
KQL

  aca_kql_env_filter_tier = {
    for tier, row in local.aca_tiers :
    tier => (
      length(coalesce(try(var.aca_environment_log_names[tier], null), [])) == 1
      ? "EnvironmentName_s == '${var.aca_environment_log_names[tier][0]}'"
      : length(coalesce(try(var.aca_environment_log_names[tier], null), [])) > 1
      ? "EnvironmentName_s in (${join(", ", [for n in var.aca_environment_log_names[tier] : "'${n}'"])})"
      : ""
    )
  }

  aca_kql_job_scope = local.aca_kql_env_filter_tier
  aca_kql_app_scope = local.aca_kql_env_filter_tier

  aca_sizing_resource_groups_literal = {
    for tier, row in local.aca_tiers :
    tier => join(", ", [for rg in row.resource_groups : "'${rg}'"])
  }

  aca_kql_for_alert = merge(
    {
      for k, row in local.aca_alert_rule_matrix :
      k => <<-KQL
ContainerAppSystemLogs_CL
| where TimeGenerated > ago(15m)
| where isnotempty(JobName_s)
| where ${local.aca_kql_job_scope[row.tier]}
| where ${local.aca_kql_job_failure}
| summarize FailureCount = count(), Reasons = make_set(Reason_s, 5) by EnvironmentName_s, JobName_s
| extend JobDetail = strcat(JobName_s, "(", strcat_array(Reasons, "/"), ")")
| summarize FailureCount = sum(FailureCount), JobDetails = make_set(JobDetail, 50) by EnvironmentName_s
| extend AlertScope = strcat("jobs: ", strcat_array(JobDetails, ", "))
| project FailureCount, AlertScope
KQL
      if row.rule_key == "job_startup_failure" && local.aca_kql_job_scope[row.tier] != ""
    },
    {
      for k, row in local.aca_alert_rule_matrix :
      k => <<-KQL
ContainerAppSystemLogs_CL
| where TimeGenerated > ago(15m)
| where isnotempty(ContainerAppName_s)
| where ${local.aca_kql_app_scope[row.tier]}
| where ${local.aca_kql_app_failure}
${local.aca_kql_app_failure_reason}
| summarize FailureCount = count(), Reasons = make_set(FailureReason, 5) by EnvironmentName_s, ContainerAppName_s
${row.rule.threshold > 0 ? "| where FailureCount > ${row.rule.threshold}" : ""}
| extend AppDetail = strcat(ContainerAppName_s, "(", strcat_array(Reasons, "/"), ")")
| summarize FailureCount = sum(FailureCount), AppDetails = make_set(AppDetail, 50) by EnvironmentName_s
| extend AlertScope = strcat("apps: ", strcat_array(AppDetails, ", "))
| project FailureCount, AlertScope
KQL
      if row.rule_key == "app_startup_failure" && local.aca_kql_app_scope[row.tier] != ""
    },
    {
      for k, row in local.aca_alert_rule_matrix :
      k => <<-KQL
ContainerAppSystemLogs_CL
| where TimeGenerated > ago(${row.rule.window_minutes}m)
| where isnotempty(ContainerAppName_s)
| where ${local.aca_kql_app_scope[row.tier]}
| where ${local.aca_kql_app_restart}
| summarize RestartCount = count() by ContainerAppName_s
KQL
      if row.rule_key == "app_restart" && local.aca_kql_app_scope[row.tier] != ""
    },
    {
      for k, row in local.aca_alert_rule_matrix :
      k => <<-KQL
AzureMetrics
| where TimeGenerated > ago(${row.rule.window_minutes}m)
| where _ResourceId has "/Microsoft.App/containerApps/"
| where ResourceGroup in (${local.aca_sizing_resource_groups_literal[row.tier]})
| extend AppName = tostring(split(_ResourceId, "/")[-1])
| where MetricName == "MemoryPercentage"
| summarize MemPct = avg(Average) by AppName
| where MemPct > ${row.rule.threshold_percent}
| extend AppDetail = strcat(AppName, "(", round(MemPct, 1), "%)")
| summarize BreachCount = count(), AppDetails = make_set(AppDetail, 50)
| extend AlertScope = strcat("apps: ", strcat_array(AppDetails, ", "))
| project BreachCount, AlertScope
KQL
      if row.rule_key == "app_memory_high"
    },
    {
      for k, row in local.aca_alert_rule_matrix :
      k => <<-KQL
AzureMetrics
| where TimeGenerated > ago(${row.rule.window_minutes}m)
| where _ResourceId has "/Microsoft.App/containerApps/"
| where ResourceGroup in (${local.aca_sizing_resource_groups_literal[row.tier]})
| extend AppName = tostring(split(_ResourceId, "/")[-1])
| where MetricName == "CpuPercentage"
| summarize CpuPct = max(Maximum) by AppName
| where CpuPct > ${row.rule.threshold_percent}
| extend AppDetail = strcat(AppName, "(", round(CpuPct, 1), "%)")
| summarize BreachCount = count(), AppDetails = make_set(AppDetail, 50)
| extend AlertScope = strcat("apps: ", strcat_array(AppDetails, ", "))
| project BreachCount, AlertScope
KQL
      if row.rule_key == "app_cpu_high"
    },
    {
      for k, row in local.aca_alert_rule_matrix :
      k => <<-KQL
AzureDiagnostics
| where TimeGenerated > ago(${row.rule.window_minutes}m)
| where ResourceProvider == "MICROSOFT.DBFORPOSTGRESQL"
| where Category == "PostgreSQLLogs"
| where ResourceGroup in~ (${local.aca_sizing_resource_groups_literal[row.tier]})
| where Message has_any ("database system was shut down at", "database system was interrupted", "database system is ready to accept connections")
| extend StopAt = todatetime(strcat(extract(@"at (\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}) UTC", 1, Message), "Z"))
| summarize RestartCount = dcountif(Message, Message has "ready to accept connections"),
            ReadyAt = maxif(TimeGenerated, Message has "ready to accept connections"),
            StopAt = maxif(StopAt, isnotempty(StopAt)),
            Server = tostring(any(Resource)) by ResourceGroup
| where RestartCount > 0
| extend DownSec = datetime_diff("second", ReadyAt, StopAt)
| extend AlertScope = strcat(ResourceGroup, ": ", Server, " down ", DownSec, "s")
| project RestartCount, AlertScope
KQL
      if row.rule_key == "pg_restart"
    },
  )
}
