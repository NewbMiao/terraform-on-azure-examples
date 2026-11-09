output "budget_amounts" {
  description = "Monthly budget ceiling per RG (baseline × headroom, rounded)."
  value       = local.budget_amounts
}

output "relay_dev_notifications" {
  description = "The three alert shapes (relay dev RG); compare threshold_type at plan time."
  value       = terraform_data.rg_budget["RG-RELAY-DEV-SEA"].input.notifications
}

output "subscription_anomaly_alert" {
  description = "Subscription-level Cost Anomaly Alert (created only when RG rows exist)."
  value       = length(terraform_data.subscription_cost_anomaly) > 0 ? terraform_data.subscription_cost_anomaly[0].input : null
}
