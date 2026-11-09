locals {
  pipeline_folder_allow_permissions = {
    ViewBuildDefinition   = "Allow"
    EditBuildDefinition   = "Allow"
    QueueBuilds           = "Allow"
    CreateBuildDefinition = "Allow"
  }

  pipeline_folder_rules = {
    for team_key, cfg in var.team_ado :
    team_key => {
      path        = cfg.pipeline_path
      owner_team  = team_key
      owner_group = var.teams[team_key].security_group.display_name
    }
  }
}

resource "terraform_data" "pipeline_folder_acl" {
  for_each = local.pipeline_folder_rules

  input = merge(each.value, {
    azure_resource = "azuredevops_build_folder_permissions"
    permissions    = local.pipeline_folder_allow_permissions
  })
}
