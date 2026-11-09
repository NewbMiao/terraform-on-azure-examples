output "application_access_groups" {
  value = {
    for app_key, app in local.application_groups :
    app_key => {
      display_name        = app.display_name
      assignment_required = app.assignment_required
      sso_group_name      = app.sso_group_name
      nested_groups       = app.nested_groups
    }
  }
}

output "nest_source_expansion" {
  value = {
    sources            = { for name, upns in local.nest_source_members : name => sort(upns) }
    app_direct_members = { for app_key, upns in local.app_direct_members : app_key => sort(upns) }
    app_member_sources = local.app_member_sources
  }
}

output "user_id_cache" {
  value = {
    cached_upns                = sort(keys(local.cached_member_object_ids))
    uncached_upns              = local.uncached_upns
    resolved_member_object_ids = local.resolved_member_object_ids
  }
}

output "logic_app_trigger_oauth" {
  value = {
    oauth_audience = var.logic_app.oauth_audience
    oauth_issuer   = local.logic_app_oauth_issuer
    policies       = local.logic_app_oauth_policies
  }
}

output "logic_app_catalog" {
  value = local.logic_app_catalog
}

output "logic_app_access_boundary" {
  value = {
    name              = var.logic_app.name
    caller_policies   = keys(var.logic_app.caller_apps)
    approval_required = var.logic_app.approval_required
    supports_batch    = var.logic_app.supports_batch
    callback_enabled  = var.logic_app.callback_enabled
  }
}
