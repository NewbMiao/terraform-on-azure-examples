locals {
  acr_scope_token_assignments = {
    for team_key in local.team_keys :
    team_key => {
      azure_resource = "azurerm_container_registry_scope_map"
      registry_name  = var.shared_acr_name
      path           = "${team_key}/"
      team_key       = team_key
      token          = "pull"
    }
  }
}

resource "terraform_data" "acr_scope_token" {
  for_each = local.acr_scope_token_assignments

  input = each.value
}
