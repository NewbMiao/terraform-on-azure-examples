# Real resource: data "azuread_user" { user_principal_name = each.value }
# The example doesn't call Graph; for_each covers only uncached_upns, avoiding one lookup per person as rosters grow.
resource "terraform_data" "uncached_user_lookup" {
  for_each = toset(local.uncached_upns)

  input = {
    azure_data_source    = "azuread_user"
    user_principal_name  = each.value
    resolved_object_id   = "88888888-8888-4888-8888-888888888888"
    graph_field_on_apply = "data.azuread_user.<key>.object_id"
  }
}

locals {
  member_object_ids_from_graph = {
    for upn, row in terraform_data.uncached_user_lookup :
    upn => row.input.resolved_object_id
  }

  resolved_member_object_ids = merge(
    local.cached_member_object_ids,
    local.member_object_ids_from_graph,
  )
}
