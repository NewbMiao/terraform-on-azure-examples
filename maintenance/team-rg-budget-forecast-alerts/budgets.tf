# Plays data "azurerm_resource_group" — resolves ids from the RG names in the sheet
resource "terraform_data" "resource_group" {
  for_each = var.resource_groups

  input = {
    name = each.key
    id   = "/subscriptions/00000000-0000-0000-0000-000000000101/resourceGroups/${each.key}"
  }
}

# Plays azurerm_consumption_budget_resource_group
resource "terraform_data" "rg_budget" {
  for_each = var.resource_groups

  input = {
    name              = substr("bgt-${replace(replace(lower(each.key), "-", ""), "sea01", "sea")}", 0, 63)
    resource_group_id = terraform_data.resource_group[each.key].input.id
    amount            = local.budget_amounts[each.key]
    time_grain        = "Monthly"
    time_period = {
      start_date = var.budget_start_date
    }
    notifications = [
      for key, tmpl in local.budget_notification_templates : merge(tmpl, {
        enabled        = true
        operator       = "GreaterThan"
        contact_groups = [var.cloudops_action_group.id]
        contact_emails = coalesce(each.value.contact_emails, [])
      })
    ]
  }
}
