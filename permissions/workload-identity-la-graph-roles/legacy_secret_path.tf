# Contrast: legacy Entra app + client secret in KV (no plaintext, no password value in this example)
resource "terraform_data" "legacy_entra_application" {
  for_each = { for k, v in var.legacy_entra_apps : k => v if coalesce(v.enabled, false) }

  input = {
    azure_resource = "azuread_application"
    display_name   = each.value.display_name
    team_key       = each.value.team_key
    environment    = each.value.environment
  }
}

resource "terraform_data" "legacy_key_vault_secret_reference" {
  for_each = { for k, v in var.legacy_entra_apps : k => v if coalesce(v.enabled, false) }

  input = {
    azure_resource = "azurerm_key_vault_secret"
    name           = each.value.key_vault_secret_name
    note           = "The example writes no secret value; in the real stack a rotation process injects it"
  }
}

resource "terraform_data" "legacy_graph_app_role_assignment" {
  for_each = local.legacy_graph_role_assignments

  input = {
    azure_resource      = "azuread_app_role_assignment"
    app_role_id         = each.value.app_role_id
    principal_object_id = each.value.principal_id
    resource_object_id  = var.graph_api.service_principal_object_id
    legacy_app_key      = each.value.legacy_app_key
    role_name           = each.value.role_name
    auth_mode           = "client_secret"
  }
}
