# Contrast only: module-level check when callers upgrade (not run by tfpolicy).
# Real resource: azurerm_storage_account via a storage module wrapper.

terraform {
  required_version = ">= 1.5.0"
}

variable "allow_nested_items_to_be_public" {
  type    = bool
  default = false
}

check "storage_account_no_public_blob" {
  assert {
    condition     = !var.allow_nested_items_to_be_public
    error_message = "This module does not allow blob public access; keep allow_nested_items_to_be_public false."
  }
}