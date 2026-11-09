# A source group is itself an Entra group: members land here once, downstream Apps reference it via nested_groups.
# Real resource: azuread_group (looked up by display_name for the existing SGRP-*)
resource "terraform_data" "nest_source_group" {
  for_each = var.nest_sources

  input = {
    azure_resource = "azuread_group"
    display_name   = each.key
    group_kind     = "nest source"
  }
}

locals {
  # "source group/UPN" as the key: a source writes its members once, repeat references don't rewrite
  nest_source_bindings = merge([
    for group_name, upns in local.nest_source_members : {
      for upn in upns :
      "${group_name}/${upn}" => {
        group_name = group_name
        upn        = upn
        object_id  = local.resolved_member_object_ids[upn]
      }
    }
  ]...)
}

# Real resource: azuread_group_member
resource "terraform_data" "nest_source_member" {
  for_each = local.nest_source_bindings

  input = {
    azure_resource = "azuread_group_member"
    group_name     = each.value.group_name
    upn            = each.value.upn
    object_id      = each.value.object_id
    membership     = "nest source"
  }
}
