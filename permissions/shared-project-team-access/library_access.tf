locals {
  library_project_deny_permissions = {
    View        = "Deny"
    Use         = "Deny"
    Administer  = "Deny"
    ViewSecrets = "Deny"
    Owner       = "Deny"
    Create      = "Deny"
  }

  library_vg_role = merge(
    { for name, _ in local.kv_variable_groups : name => "Administrator" },
    { (local.shared_variable_group) = "Reader" },
  )

  library_variable_group_grants = merge([
    for team_key, cfg in var.team_ado : {
      for vg_name, vg_id in cfg.library.variable_groups :
      "${team_key}/${vg_name}" => {
        azure_resource    = "azuredevops_securityrole_assignment"
        scope             = "distributedtask.variablegroup"
        team_key          = team_key
        variable_group    = vg_name
        variable_group_id = vg_id
        role_name         = local.library_vg_role[vg_name]
        key_vault         = try(local.kv_variable_groups[vg_name].kv_name, null)
        scope_rg          = try(local.kv_variable_groups[vg_name].scope_rg, null)
      }
    }
  ]...)

  library_environment_grants = merge([
    for team_key, cfg in var.team_ado : {
      for env_name, env_id in cfg.library.environments :
      "${team_key}/${env_name}" => {
        azure_resource = "azuredevops_securityrole_assignment"
        scope          = "distributedtask.environmentreferencerole"
        team_key       = team_key
        environment    = env_name
        environment_id = env_id
        role_name      = "Administrator"
      }
    }
  ]...)
}

# In production: ado_team_isolation.deny_project_library — first deny project-level Library visibility, then Allow per catalog entry
resource "terraform_data" "library_project_deny" {
  for_each = var.team_ado

  input = {
    azure_resource = "azuredevops_library_permissions"
    team_key       = each.key
    ado_group      = local.ado_team_display_name[each.key]
    permissions    = local.library_project_deny_permissions
  }
}

resource "terraform_data" "library_variable_group_allow" {
  for_each = local.library_variable_group_grants

  input = each.value
}

resource "terraform_data" "library_environment_allow" {
  for_each = local.library_environment_grants

  input = each.value
}
