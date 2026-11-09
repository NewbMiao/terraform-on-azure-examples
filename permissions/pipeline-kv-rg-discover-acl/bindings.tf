check "access_scopes_team_slug" {
  assert {
    condition = alltrue([
      for _, scope in var.access_scopes :
      contains(keys(var.team_principal_ids), scope.team_slug)
      if coalesce(scope.enabled, true)
    ])
    error_message = "access_scopes.team_slug must have a matching principal in team_principal_ids."
  }
}

# Real resource: azurerm_key_vault_access_policy
resource "terraform_data" "access_binding" {
  for_each = local.policy_assignments

  input = {
    azure_resource      = "azurerm_key_vault_access_policy"
    vault_id            = each.value.vault_id
    principal_id        = each.value.principal_id
    principal_kind      = each.value.kind
    team_slug           = each.value.team_slug
    resource_group_name = each.value.resource_group_name
    subscription_key    = each.value.subscription_key
    secret_permissions  = each.value.secret_permissions
  }
}
