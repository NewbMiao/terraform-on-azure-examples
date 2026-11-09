# harbor · some CKVs can be skipped after review (see the comment blocks in .checkov.yaml); firewall/soft-delete checks may still fail on their own.
resource "azurerm_resource_group" "harbor" {
  name     = "rg-harbor-eg-demo"
  location = "southeastasia"
}

resource "azurerm_key_vault" "harbor" {
  name                = "kv-harbor-eg-demo"
  location            = azurerm_resource_group.harbor.location
  resource_group_name = azurerm_resource_group.harbor.name
  tenant_id           = "11111111-1111-1111-1111-111111111111"
  sku_name            = "standard"

  soft_delete_retention_days    = 7
  public_network_access_enabled = true
}
