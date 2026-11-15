# Org-wide rule: Storage Account blob public access off (lesson tooling/tfpolicy-hcl-policy).

resource_policy "azurerm_storage_account" "no_public_nested_blobs" {
  enforcement_level = "mandatory"

  enforce {
    condition     = attrs.allow_nested_items_to_be_public == false
    error_message = "Storage account must set allow_nested_items_to_be_public = false."
  }
}