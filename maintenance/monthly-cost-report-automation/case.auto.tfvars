subscriptions = {
  dev  = { subscription_id = "00000000-0000-0000-0000-000000000101" }
  prod = { subscription_id = "00000000-0000-0000-0000-000000000102" }
}

automation = {
  enabled                       = true
  resource_group_name           = "RG-EG-HUB-INF"
  account_name                  = "auto-eg-hub-01"
  cost_reader_subscription_keys = ["dev", "prod"]

  monthly_cost_report = {
    enabled      = true
    runbook_name = "app-monthly-cost-report"
    schedule = {
      timezone     = "Asia/Shanghai"
      day_of_month = 1
      hour         = 8
      minute       = 30
    }
    resource_groups = {
      dev = {
        subscription_key = "dev"
        items = {
          "RG-RELAY-DEV-SEA" = { team = "relay" }
          "RG-PULSE-DEV-SEA" = { team = "pulse" }
        }
      }
      prod = {
        subscription_key = "prod"
        items = {
          "RG-RELAY-PRD-SEA" = { team = "relay" }
        }
      }
    }
    budget_pins = {
      "RG-RELAY-DEV-SEA" = 1000
      "RG-PULSE-DEV-SEA" = 150
      "RG-RELAY-PRD-SEA" = 1200
    }
    email = {
      enabled    = true
      sender     = "reports-bot@example.com"
      recipients = "cloudops@example.com,owen.relay@example.com"
    }
  }
}
