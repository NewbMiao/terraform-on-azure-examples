# Plays azurerm_monitor_action_group (platform HUB monitoring RG)
resource "terraform_data" "cloudops_action_group" {
  input = {
    name                = var.cloudops_action_group.name
    resource_group_name = "RG-EG-HUB-MON-SEA"
    short_name          = "cloudops"
    email_addresses     = ["cloudops@example.com"]
  }
}

resource "terraform_data" "team_action_group" {
  for_each = var.team_action_groups

  input = {
    name                = "ag-app-${each.key}"
    resource_group_name = "RG-EG-HUB-MON-SEA"
    short_name          = substr("app${replace(each.key, "-", "")}", 0, 12)
    email_addresses     = each.value.email_addresses
    security_group_name = try(each.value.security_group_name, null)
  }
}
