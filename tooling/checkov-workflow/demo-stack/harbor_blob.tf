# harbor · team-level Blob (no Queue logging) — CKV_AZURE_33 is a Deferred skip in .checkov.yaml; not part of that night's MR.
resource "azurerm_storage_account" "harbor_blob" {
  name                     = "stregharborblob01"
  resource_group_name      = azurerm_resource_group.harbor.name
  location                 = azurerm_resource_group.harbor.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  allow_nested_items_to_be_public = false
  min_tls_version                 = "TLS1_2"
}
