# Plays azurerm_automation_account
resource "terraform_data" "automation_account" {
  count = var.automation.enabled ? 1 : 0

  input = {
    name                     = var.automation.account_name
    resource_group_name      = var.automation.resource_group_name
    sku_name                 = "Basic"
    identity_type            = "SystemAssigned"
    identity_principal_id    = "11111111-1111-1111-1111-111111111111"
    runtime_environment_name = "Python-3.10"
  }
}
