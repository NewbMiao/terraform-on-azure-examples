# Each source produces one value; KV copies all read from here instead of storing their own.
locals {
  source_values = {
    pg    = { value = random_password.admin.result, expiration_date = null }
    entra = { value = local.adopted_password.value, expiration_date = local.adopted_password.end_date }
  }
}

# Plays azurerm_key_vault_secret: both source kinds share one for_each.
resource "terraform_data" "key_vault_secret" {
  for_each = var.key_vault_secrets

  input = {
    name            = each.value.secret_name
    key_vault       = each.value.vault
    source          = each.value.source
    content_type    = each.value.content_type
    value_sha256    = sha256(local.source_values[each.value.source].value)
    expiration_date = local.source_values[each.value.source].expiration_date
  }

  lifecycle {
    precondition {
      condition     = local.source_values[each.value.source].value != ""
      error_message = "The source value is empty: fill in the plaintext for ${each.value.source} first, then push state."
    }
  }
}
