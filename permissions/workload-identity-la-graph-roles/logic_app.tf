# Plays azurerm_logic_app_workflow (system-assigned MI)
resource "terraform_data" "logic_app_workflow" {
  for_each = var.workloads

  input = {
    azure_resource      = "azurerm_logic_app_workflow"
    name                = each.value.display_name
    resource_group_name = each.value.resource_group_name
    location            = each.value.location
    team_key            = each.value.team_key
    environment         = each.value.environment
    identity = {
      type = "SystemAssigned"
    }
    # After a real apply this comes from identity[0].principal_id; here a fictional id from the configuration sheet demonstrates the wiring
    principal_id = each.value.managed_identity_principal_id
  }
}
