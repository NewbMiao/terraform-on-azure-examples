locals {
  # In production: ado_team_service_connection_access — each team explicitly lists SC names (including the team ACR scope-token SC)
  team_service_connection_allow = merge([
    for team_key, cfg in var.team_ado : {
      for sc_name in cfg.service_connection_names :
      "${team_key}/${sc_name}" => {
        azure_resource     = "azuredevops_serviceendpoint_permissions"
        team_key           = team_key
        ado_group          = local.ado_team_display_name[team_key]
        service_connection = sc_name
        permissions = {
          Use               = "allow"
          ViewEndpoint      = "allow"
          ViewAuthorization = "allow"
        }
      }
    }
  ]...)

  team_sc_allow_list = {
    for team_key, cfg in var.team_ado :
    team_key => sort(cfg.service_connection_names)
  }

  # Team SC names should be sc-{team}-*
  team_sc_name_mismatches = flatten([
    for team_key, cfg in var.team_ado : [
      for sc_name in cfg.service_connection_names :
      "${team_key}/${sc_name}"
      if !startswith(sc_name, "sc-${team_key}-")
    ]
  ])
}

resource "terraform_data" "service_connection_allow" {
  for_each = local.team_service_connection_allow

  input = each.value
}
