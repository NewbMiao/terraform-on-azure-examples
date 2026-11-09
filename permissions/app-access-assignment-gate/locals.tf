locals {
  # Source group → roster: each source is maintained here only, shared by multiple Apps
  nest_source_members = {
    for group_name, upns in var.nest_sources :
    group_name => distinct(upns)
  }

  # An SSO group's direct members = the App's own exceptions ∪ members of the referenced sources (deduplicated).
  # Enterprise applications only count direct members, so we expand exactly one level — the same math as Assignment required.
  app_direct_members = {
    for app_key, app in var.applications :
    app_key => distinct(concat(
      app.members,
      flatten([for name in app.nested_groups : local.nest_source_members[name]]),
    ))
  }

  # Which sources brought in each member; exception members get an empty list
  app_member_sources = {
    for app_key, app in var.applications : app_key => {
      for upn in local.app_direct_members[app_key] : upn => [
        for name in app.nested_groups : name
        if contains(local.nest_source_members[name], upn)
      ]
    }
  }

  application_groups = {
    for app_key, app in var.applications :
    app_key => {
      app_key                 = app_key
      display_name            = app.display_name
      sso_group_name          = app.sso_group_name
      assignment_required     = app.app_role_assignment_required
      group_membership_claims = app.group_membership_claims
      nested_groups           = app.nested_groups
    }
  }

  # People needing an object_id resolved = source members ∪ each App's direct members
  all_member_upns = toset(concat(
    flatten([for upns in local.nest_source_members : upns]),
    flatten([for upns in local.app_direct_members : upns]),
  ))

  # Consult var.user_object_ids first; missed UPNs go into uncached_upns and are resolved by id_cache.tf.
  member_object_ids_from_cache = {
    for upn in local.all_member_upns :
    upn => lookup(var.user_object_ids, lower(upn), null)
  }

  uncached_upns = sort([
    for upn, object_id in local.member_object_ids_from_cache :
    upn if object_id == null
  ])

  cached_member_object_ids = {
    for upn, object_id in local.member_object_ids_from_cache :
    upn => object_id if object_id != null
  }
}
