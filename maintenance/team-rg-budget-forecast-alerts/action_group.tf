# Plays azurerm_monitor_action_group — the platform cloudops recipients are maintained here only
resource "terraform_data" "cloudops_action_group" {
  input = {
    id              = var.cloudops_action_group.id
    name            = var.cloudops_action_group.name
    email_receivers = ["cloudops@example.com"]
  }
}
