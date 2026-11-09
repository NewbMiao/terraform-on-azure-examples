# Storage written in that night's MR — real problems left in on purpose: not registered in this example's skip list, so CKVs still fire after the skips.
resource "azurerm_storage_account" "relay_blob" {
  name                     = "stregharborrelay01"
  resource_group_name      = azurerm_resource_group.harbor.name
  location                 = azurerm_resource_group.harbor.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  allow_nested_items_to_be_public = true
  min_tls_version                 = "TLS1_0"
}
