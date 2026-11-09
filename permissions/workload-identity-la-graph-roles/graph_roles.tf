# Plays azuread_app_role_assignment — the permission hangs on the LA MI's service principal
resource "terraform_data" "graph_app_role_assignment" {
  for_each = local.graph_role_assignments

  input = {
    azure_resource      = "azuread_app_role_assignment"
    app_role_id         = each.value.app_role_id
    principal_object_id = each.value.principal_id
    resource_object_id  = var.graph_api.service_principal_object_id
    workload_key        = each.value.workload_key
    team_key            = each.value.team_key
    environment         = each.value.environment
    role_name           = each.value.role_name
    auth_mode           = each.value.auth_mode
  }
}
