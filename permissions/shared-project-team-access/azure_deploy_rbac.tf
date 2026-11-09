locals {
  # Each team connection gets two RBAC assignments in Azure (paired with the WIF deploy identity) — scope is the team RG, not the subscription
  deploy_rbac_assignments = merge([
    for sc_key, sc in local.team_service_connections : {
      "${sc_key}/contributor" = {
        azure_resource       = "azurerm_role_assignment"
        role_definition_name = "Contributor"
        principal_display    = sc.identity # in production: azuread_service_principal.ado_sc[sc_name].object_id
        scope_kind           = sc.scope_kind
        scope_rg             = sc.scope_rg
        provider_alias       = local.provider_alias_by_subscription_key[sc.subscription_key]
        service_connection   = sc.name
      }
      "${sc_key}/kv_secrets_user" = {
        azure_resource       = "azurerm_role_assignment"
        role_definition_name = "Key Vault Secrets User"
        principal_display    = sc.identity
        scope_kind           = sc.scope_kind
        scope_rg             = sc.scope_rg
        provider_alias       = local.provider_alias_by_subscription_key[sc.subscription_key]
        service_connection   = sc.name
      }
    }
  ]...)
}

resource "terraform_data" "deploy_rbac_assignment" {
  for_each = local.deploy_rbac_assignments

  input = each.value
}
