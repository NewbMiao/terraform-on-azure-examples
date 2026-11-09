# Plays azurerm_application_insights_workbook; the KQL body comes from rank.kql in the same directory.
resource "terraform_data" "aks_sizing_workbook" {
  input = {
    name                = "wb-pulse-aks-sizing"
    resource_group_name = var.workbook.resource_group
    location            = var.workbook.location
    display_name        = var.workbook.display_name
    source_id           = lower(var.workbook.lgw_workspace_id)
    category            = "workbook"
    data_json           = local.workbook_data_json
  }
}
