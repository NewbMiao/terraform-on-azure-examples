locals {
  # Matches the aca_alerts module's built-in defaults; the lesson's "sample presets" table + the case below only override the deltas
  aca_rule_defaults = {
    job_startup_failure = {
      enabled   = true
      threshold = 0
    }
    app_startup_failure = {
      enabled   = true
      threshold = 0
    }
    app_restart = {
      enabled        = false
      threshold      = 4
      window_minutes = 15
    }
    app_memory_high = {
      enabled           = false
      threshold_percent = 90
      window_minutes    = 15
      aggregation       = "Average"
    }
    app_cpu_high = {
      enabled           = false
      threshold_percent = 95
      window_minutes    = 15
      aggregation       = "Maximum"
    }
    pg_restart = {
      enabled        = false
      window_minutes = 5
    }
  }

  aca_tier_team_key = {
    for tier, cfg in var.aca_alerts :
    tier => coalesce(
      try(cfg.action_group.team_key, null),
      endswith(tier, "-nonprod") ? trimsuffix(tier, "-nonprod") : (
        endswith(tier, "-prod") ? trimsuffix(tier, "-prod") : tier
      ),
    )
  }

  aca_tiers = {
    for tier, cfg in var.aca_alerts :
    tier => {
      tier             = tier
      team_key         = local.aca_tier_team_key[tier]
      resource_groups  = cfg.resource_groups
      severity         = coalesce(cfg.severity, endswith(tier, "-prod") ? 1 : 2)
      include_cloudops = coalesce(try(cfg.action_group.include_cloudops, null), true)
      rules = {
        job_startup_failure = merge(
          local.aca_rule_defaults.job_startup_failure,
          try(cfg.rules.job_startup_failure, {}),
        )
        app_startup_failure = merge(
          local.aca_rule_defaults.app_startup_failure,
          try(cfg.rules.app_startup_failure, {}),
        )
        app_restart = merge(
          local.aca_rule_defaults.app_restart,
          try(cfg.rules.app_restart, {}),
        )
        app_memory_high = merge(
          local.aca_rule_defaults.app_memory_high,
          try(cfg.rules.app_memory_high, {}),
        )
        app_cpu_high = merge(
          local.aca_rule_defaults.app_cpu_high,
          try(cfg.rules.app_cpu_high, {}),
        )
        pg_restart = merge(
          local.aca_rule_defaults.pg_restart,
          try(cfg.rules.pg_restart, {}),
        )
      }
    }
  }

  aca_rule_data_plane = {
    job_startup_failure = "container_app_system_logs"
    app_startup_failure = "container_app_system_logs"
    app_restart         = "container_app_system_logs"
    app_memory_high     = "azure_metrics"
    app_cpu_high        = "azure_metrics"
    pg_restart          = "azure_diagnostics_pg"
  }

  # tier × rule key; only enabled ones produce a scheduled_query_rules_alert_v2
  aca_alert_rule_matrix = merge([
    for tier, row in local.aca_tiers : {
      for rule_key, rule in row.rules :
      "${tier}|${rule_key}" => {
        tier             = tier
        team_key         = row.team_key
        rule_key         = rule_key
        resource_groups  = row.resource_groups
        severity         = row.severity
        include_cloudops = row.include_cloudops
        rule             = rule
        data_plane       = local.aca_rule_data_plane[rule_key]
      }
      if try(rule.enabled, false) && (
        !contains(["job_startup_failure", "app_startup_failure", "app_restart"], rule_key)
        || local.aca_kql_env_filter_tier[tier] != ""
      )
    }
  ]...)

  aca_tier_action_group_names = {
    for tier, row in local.aca_tiers :
    tier => concat(
      row.include_cloudops ? [var.cloudops_action_group.name] : [],
      ["ag-app-${row.team_key}"],
    )
  }

  # The alert shell shared by the five rule classes (scope, action group, muting)
  aca_alert_input_common = {
    for k, row in local.aca_alert_rule_matrix :
    k => {
      name                = "aca-${row.tier}-${replace(row.rule_key, "_", "-")}"
      tier                = row.tier
      resource_group_name = row.resource_groups[0]
      resource_groups     = row.resource_groups
      scopes              = [var.org_log_analytics_workspace_id]
      severity            = row.severity
      action_groups       = local.aca_tier_action_group_names[row.tier]
      mute_after          = "PT30M"
      alert_scope_shape   = "apps: <name>(<reason>), ..."
    }
  }

  # On/off overview of all five classes (including enabled = false, for comparison against the lesson table)
  aca_alert_catalog_by_tier = {
    for tier, row in local.aca_tiers :
    tier => {
      for rule_key, rule in row.rules :
      rule_key => {
        enabled           = rule.enabled
        threshold         = try(rule.threshold, null)
        threshold_percent = try(rule.threshold_percent, null)
        window_minutes    = try(rule.window_minutes, null)
        aggregation       = try(rule.aggregation, null)
        data_plane        = local.aca_rule_data_plane[rule_key]
      }
    }
  }
}
