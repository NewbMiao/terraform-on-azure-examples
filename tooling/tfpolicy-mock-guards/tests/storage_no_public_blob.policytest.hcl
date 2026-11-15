# Pulse legacy pass/fail vs relay-compliant account (EG fictional names).

policytest {
  targets = ["../policies/storage_no_public_blob.policy.hcl"]
}

resource "azurerm_storage_account" "relay_dev_ok" {
  attrs = {
    name                            = "stegrelaydevblob01"
    resource_group_name             = "RG-RELAY-DEV-SEA-01"
    location                        = "southeastasia"
    account_tier                    = "Standard"
    account_replication_type        = "LRS"
    allow_nested_items_to_be_public = false
  }
}

resource "azurerm_storage_account" "pulse_legacy_public" {
  expect_failure = true

  attrs = {
    name                            = "stegpulselegacy01"
    resource_group_name             = "RG-PULSE-DEV-SEA-01"
    location                        = "southeastasia"
    account_tier                    = "Standard"
    account_replication_type        = "LRS"
    allow_nested_items_to_be_public = true
  }
}