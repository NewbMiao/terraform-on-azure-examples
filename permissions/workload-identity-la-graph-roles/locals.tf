locals {
  graph_role_assignments = merge([
    for workload_key, workload in var.workloads : {
      for role_name in workload.graph_roles :
      "${workload_key}:${role_name}" => {
        workload_key = workload_key
        team_key     = workload.team_key
        environment  = workload.environment
        role_name    = role_name
        app_role_id  = var.graph_api.app_roles[role_name]
        principal_id = workload.managed_identity_principal_id
        auth_mode    = workload.use_managed_identity_for_graph ? "managed_identity" : "client_secret"
      }
      if workload.use_managed_identity_for_graph
    }
  ]...)

  legacy_graph_role_assignments = merge([
    for app_key, app in var.legacy_entra_apps : {
      for role_name in app.graph_roles :
      "legacy:${app_key}:${role_name}" => {
        legacy_app_key = app_key
        display_name   = app.display_name
        role_name      = role_name
        app_role_id    = var.graph_api.app_roles[role_name]
        # Legacy style: the role hangs on a separately registered Entra app SP (a fixed fictional principal in this example)
        principal_id          = "cccccccc-cccc-4ccc-8ccc-cccccccccccc"
        key_vault_secret_name = app.key_vault_secret_name
      }
      if coalesce(app.enabled, false)
    }
  ]...)
}
