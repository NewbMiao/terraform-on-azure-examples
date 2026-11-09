# Plays azurerm_cost_anomaly_alert — subscription-level daily anomaly (configured together with the RG budgets of the same env)
resource "terraform_data" "subscription_cost_anomaly" {
  count = length(var.resource_groups) > 0 ? 1 : 0

  input = {
    name            = "anomaly-${lower(var.anomaly_label)}"
    display_name    = "Daily anomaly ${var.anomaly_label}"
    subscription_id = "/subscriptions/${var.subscription_id}"
    email_addresses = var.cloudops_emails
    email_subject   = "Cost anomaly detected — ${var.anomaly_display_name}"
  }
}
