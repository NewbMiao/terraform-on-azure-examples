locals {
  acr_scope_token_assignments = merge([
    for registry_key, registry in var.acr_scope_tokens : {
      for path, token in registry.paths :
      "${registry_key}:${path}" => {
        registry_name = registry.registry_name
        path          = path
        team_key      = token.team_key
        token         = token.token
      }
    }
  ]...)
}

resource "terraform_data" "acr_scope_token" {
  for_each = local.acr_scope_token_assignments

  # Azure resources: azurerm_container_registry_scope_map + azurerm_container_registry_token
  input = each.value
}
