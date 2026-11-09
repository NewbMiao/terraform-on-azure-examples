# The org LGW (the one in the hub RG), and its resource ID.

locals {
  # Resource ID of the org LGW (real repos resolve it with a data source; here we assemble it from config)
  org_lgw_id = format(
    "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.OperationalInsights/workspaces/%s",
    var.subscriptions[var.org_lgw.subscription_key].id,
    var.org_lgw.resource_group,
    var.org_lgw.name,
  )
}

# Plays: azurerm_log_analytics_workspace — the org log workspace
resource "terraform_data" "org_lgw" {
  input = {
    name              = var.org_lgw.name
    resource_group    = var.org_lgw.resource_group
    subscription_key  = var.org_lgw.subscription_key
    retention_in_days = 90
  }
}
