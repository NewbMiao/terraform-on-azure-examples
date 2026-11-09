# Plays azurerm_role_assignment — one Cost Management Reader per subscription to scan
resource "terraform_data" "cost_management_reader" {
  for_each = var.automation.enabled ? toset(var.automation.cost_reader_subscription_keys) : toset([])

  input = {
    scope                = "/subscriptions/${var.subscriptions[each.key].subscription_id}"
    role_definition_name = "Cost Management Reader"
    principal_id         = local.automation_principal_id
  }
}
