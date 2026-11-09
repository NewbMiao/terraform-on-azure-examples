# Plays: azurerm_private_endpoint + the storage_pe module's inputs (team stack for_each keys)
resource "terraform_data" "storage_pe" {
  for_each = var.storage_pe

  input = {
    environment            = each.value.environment
    account_name           = each.value.account_name
    account_resource_group = each.value.account_resource_group
    subresource_names      = each.value.subresource_names
    network                = each.value.network
    private_dns            = each.value.private_dns
  }
}
