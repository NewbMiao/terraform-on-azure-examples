locals {
  raw_amounts = {
    for rg, cfg in var.resource_groups :
    rg => cfg.baseline_monthly * (1 + var.buffer_percent / 100)
  }

  round_steps = {
    for rg, raw in local.raw_amounts :
    rg => (
      raw <= 50 ? 5 :
      raw <= 200 ? 10 :
      raw <= 1000 ? 25 :
      raw <= 5000 ? 50 : 100
    )
  }

  budget_amounts = {
    for rg, raw in local.raw_amounts :
    rg => ceil(raw / local.round_steps[rg]) * local.round_steps[rg]
  }

  # Matches the production cost_budget env module: three notification templates
  budget_notification_templates = {
    actual90 = {
      threshold      = 90
      threshold_type = "Actual"
    }
    forecast100 = {
      threshold      = 100
      threshold_type = "Forecasted"
    }
    actual100 = {
      threshold      = 100
      threshold_type = "Actual"
    }
  }
}
