locals {
  git_repo_contribute_allow = {
    GenericRead             = "Allow"
    GenericContribute       = "Allow"
    CreateBranch            = "Allow"
    CreateTag               = "Allow"
    PullRequestContribute   = "Allow"
    ForcePush               = "Allow"
    Administer              = "Deny"
    ManagePermissions       = "Deny"
    DeleteRepository        = "Deny"
    RenameRepository        = "Deny"
    EditPolicies            = "Deny"
    PolicyExempt            = "Deny"
    PullRequestBypassPolicy = "Deny"
  }

  git_repo_other_teams_deny = {
    GenericRead             = "Deny"
    GenericContribute       = "Deny"
    CreateBranch            = "Deny"
    CreateTag               = "Deny"
    PullRequestContribute   = "Deny"
    ForcePush               = "Deny"
    Administer              = "Deny"
    ManagePermissions       = "Deny"
    DeleteRepository        = "Deny"
    RenameRepository        = "Deny"
    EditPolicies            = "Deny"
    PolicyExempt            = "Deny"
    PullRequestBypassPolicy = "Deny"
  }

  team_repository_grants = merge([
    for team_key, cfg in var.team_ado : {
      for repo_name, repo_cfg in cfg.git_repositories :
      "${team_key}/${repo_name}" => {
        team_key         = team_key
        repository_name  = repo_name
        owner_group      = local.ado_team_display_name[team_key]
        deny_other_teams = coalesce(repo_cfg.deny_other_teams, true)
      }
    }
  ]...)

  team_repository_other_team_denies = merge([
    for grant_key, grant in local.team_repository_grants : {
      for other_key in local.team_keys :
      "${grant_key}/${other_key}" => {
        repository_name = grant.repository_name
        deny_group      = local.ado_team_display_name[other_key]
      }
      if grant.deny_other_teams && other_key != grant.team_key
    }
  ]...)
}

resource "terraform_data" "git_repo_team_contribute" {
  for_each = local.team_repository_grants

  input = {
    azure_resource  = "azuredevops_git_permissions"
    repository_name = each.value.repository_name
    principal       = each.value.owner_group
    permissions     = local.git_repo_contribute_allow
    replace         = false
  }
}

resource "terraform_data" "git_repo_other_team_deny" {
  for_each = local.team_repository_other_team_denies

  input = {
    azure_resource  = "azuredevops_git_permissions"
    repository_name = each.value.repository_name
    principal       = each.value.deny_group
    permissions     = local.git_repo_other_teams_deny
    replace         = false
  }
}
