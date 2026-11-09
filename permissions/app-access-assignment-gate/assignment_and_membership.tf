# Real resource: azuread_service_principal
# Assignment required + one SSO group per App — the door into the Enterprise Application.
resource "terraform_data" "enterprise_application_assignment" {
  for_each = local.application_groups

  input = {
    azure_resource               = "azuread_service_principal"
    display_name                 = each.value.display_name
    app_role_assignment_required = each.value.assignment_required
    assigned_group_name          = each.value.sso_group_name
    group_membership_claims      = each.value.group_membership_claims
  }
}

# Real resource: azuread_app_role_assignment
# The default access role 00000000-0000-0000-0000-000000000000 — only means "can enter the Enterprise App", defines no in-app business role.
resource "terraform_data" "enterprise_application_group_assignment" {
  for_each = local.application_groups

  input = {
    azure_resource     = "azuread_app_role_assignment"
    application_key    = each.key
    principal_group    = each.value.sso_group_name
    app_role_id        = "00000000-0000-0000-0000-000000000000"
    assignment_purpose = "Enterprise Application access"
  }
}

locals {
  # "App/UPN" → member row; object_id comes from cache ∪ Graph, via_groups records which source brought this person in
  app_member_bindings = merge([
    for app_key, upns in local.app_direct_members : {
      for upn in upns :
      "${app_key}/${upn}" => {
        app_key        = app_key
        sso_group_name = var.applications[app_key].sso_group_name
        upn            = upn
        object_id      = local.resolved_member_object_ids[upn]
        resolution     = contains(local.uncached_upns, upn) ? "graph" : "cache"
        via_groups     = local.app_member_sources[app_key][upn]
        kind           = length(local.app_member_sources[app_key][upn]) > 0 ? "nested" : "extra"
      }
    }
  ]...)
}

# Real resource: azuread_group_member
# Members are the expanded direct members: source members + the App's own exceptions; day-to-day adds/removals can go through Logic App approval.
resource "terraform_data" "sso_group_member" {
  for_each = local.app_member_bindings

  input = {
    azure_resource = "azuread_group_member"
    application    = each.value.app_key
    group_name     = each.value.sso_group_name
    upn            = each.value.upn
    object_id      = each.value.object_id
    resolution     = each.value.resolution
    via_groups     = each.value.via_groups
    kind           = each.value.kind
  }
}
