resource "terraform_data" "project" {
  input = { name = var.project.name }
}

resource "terraform_data" "entra_team_sgrp" {
  for_each = var.teams

  input = {
    azure_resource = "data.azuread_group"
    display_name   = each.value.security_group.display_name
    object_id      = each.value.security_group.object_id
  }
}

resource "terraform_data" "ado_group_entitlement" {
  for_each = var.teams

  input = {
    azure_resource       = "azuredevops_group_entitlement"
    origin               = "aad"
    origin_id            = each.value.security_group.object_id
    account_license_type = "express"
  }
}

resource "terraform_data" "ado_team_project_group" {
  for_each = var.teams

  input = {
    azure_resource = "azuredevops_group"
    display_name   = local.ado_team_display_name[each.key]
  }
}

resource "terraform_data" "ado_team_entra_membership" {
  for_each = var.teams

  input = {
    azure_resource = "azuredevops_group_membership"
    mode           = "add"
    group          = local.ado_team_display_name[each.key]
    members        = ["azuredevops_group_entitlement.${each.key}.descriptor"]
  }
}

resource "terraform_data" "ado_team_project_view" {
  for_each = var.teams

  input = {
    azure_resource = "azuredevops_project_permissions"
    principal      = local.ado_team_display_name[each.key]
    permissions    = { GENERIC_READ = "Allow" }
  }
}
