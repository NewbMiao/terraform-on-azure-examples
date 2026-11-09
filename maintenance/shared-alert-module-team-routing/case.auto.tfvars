# Platform team catalog (one row per team)
team_action_groups = {
  relay = {
    email_addresses = ["owen.relay@example.com", "oncall-relay@example.com"]
  }
  pulse = {
    email_addresses = ["owen.pulse@example.com"]
  }
}

# The system log table has no ResourceGroup column — you can't write | where ResourceGroup in (...).
# Use EnvironmentName_s (= the first segment of the ACA managed environment's default_domain, matching the sample labels below).
# Real stacks get this injected by the parent module's managed_env_log_names_by_rg; handwritten here only to keep the sample KQL simple.
aca_environment_log_names = {
  relay-prod    = ["relay-prd-sea"]
  relay-nonprod = ["relay-dev-sea"]
}

# Team-side aca_alerts: matches the lesson's "sample presets" table
# - prod: startup rules are sensitive (threshold 0); usage off for now (enabled false, defaults match the module so they can be switched on later)
# - nonprod: app_startup threshold 1; the other startup rules stay at 0
aca_alerts = {
  relay-prod = {
    resource_groups = ["RG-RELAY-PRD-SEA"]
    action_group = {
      team_key         = "relay"
      include_cloudops = true
    }
    rules = {
      job_startup_failure = { enabled = true, threshold = 0 }
      app_startup_failure = { enabled = true, threshold = 0 }
      app_restart         = { enabled = false }
      app_memory_high     = { enabled = true, threshold_percent = 90, window_minutes = 15 }
      app_cpu_high        = { enabled = false, threshold_percent = 95, window_minutes = 15 }
      pg_restart          = { enabled = true, window_minutes = 5 }
    }
  }

  relay-nonprod = {
    resource_groups = ["RG-RELAY-DEV-SEA"]
    action_group = {
      team_key         = "relay"
      include_cloudops = true
    }
    rules = {
      job_startup_failure = { enabled = true, threshold = 0 }
      app_startup_failure = { enabled = true, threshold = 1 }
      app_restart         = { enabled = false }
      app_memory_high     = { enabled = false }
      app_cpu_high        = { enabled = false }
    }
  }
}
