cloudops_action_group = {
  id   = "/subscriptions/00000000-0000-0000-0000-000000000101/resourceGroups/RG-EG-HUB-INF/providers/Microsoft.Insights/actionGroups/ag-cloudops"
  name = "ag-cloudops"
}

subscription_id      = "00000000-0000-0000-0000-000000000101"
anomaly_label        = "APP-DEV"
anomaly_display_name = "SUB-EG-APP-DEV"
cloudops_emails      = ["cloudops@example.com"]

resource_groups = {
  "RG-RELAY-DEV-SEA" = {
    baseline_monthly = 833 # typical for recent months; ×1.2 rounded up → budget amount ≈ 1000
    contact_emails   = ["owen.relay@example.com"]
  }
  "RG-PULSE-DEV-SEA" = {
    baseline_monthly = 120
  }
}
