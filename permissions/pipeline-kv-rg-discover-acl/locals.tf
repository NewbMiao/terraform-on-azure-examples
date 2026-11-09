locals {
  # Team SC: variable groups link the vault, pipelines pull secrets — fixed read-only secret rights on ACL vaults.
  sc_secret_permissions = ["Get", "List"]

  sgrp_secret_permissions_dev = ["Get", "List", "Set", "Delete"]
  sgrp_secret_permissions_prd = ["List"]

  sgrp_secret_by_subscription = {
    dev  = local.sgrp_secret_permissions_dev
    prod = local.sgrp_secret_permissions_prd
  }

  scopes_enabled = {
    for k, v in var.access_scopes :
    k => v
    if coalesce(v.enabled, true) && contains(keys(var.team_principal_ids), v.team_slug)
  }

  principals = merge([
    for scope_key, scope in local.scopes_enabled : merge(
      {
        "${scope_key}/sgrp" = {
          scope_key    = scope_key
          team_slug    = scope.team_slug
          kind         = "sgrp"
          principal_id = var.team_principal_ids[scope.team_slug]
        }
      },
      try(scope.service_principal_id, null) != null ? {
        "${scope_key}/sp" = {
          scope_key    = scope_key
          team_slug    = scope.team_slug
          kind         = "sp"
          principal_id = scope.service_principal_id
        }
      } : {},
    )
  ]...)

  rgs_flat = merge([
    for scope_key, scope in local.scopes_enabled : {
      for rg_name, rg in scope.resource_groups :
      "${scope_key}/${rg_name}" => {
        scope_key           = scope_key
        team_slug           = scope.team_slug
        resource_group_name = rg_name
        subscription_key    = rg.subscription_key
      }
      if coalesce(rg.enabled, true)
    }
  ]...)

  # Real path: data.azurerm_resources lists vaults per RG — here vault_catalog plays the listing result.
  vault_names_by_rg = {
    for rg_key, row in local.rgs_flat :
    rg_key => [
      for vault_name, _ in try(var.vault_catalog[row.resource_group_name].vaults, {}) :
      vault_name
      if try(var.vault_catalog[row.resource_group_name].subscription_key, "") == row.subscription_key
    ]
  }

  vaults_flat = merge([
    for rg_key, vault_names in local.vault_names_by_rg : {
      for vault_name in vault_names :
      "${rg_key}/${vault_name}" => merge(local.rgs_flat[rg_key], {
        vault_name = vault_name
      })
    }
  ]...)

  vault_data = {
    for vault_key, row in local.vaults_flat :
    vault_key => {
      id        = "vault://${row.subscription_key}/${row.resource_group_name}/${row.vault_name}"
      rbac_mode = var.vault_catalog[row.resource_group_name].vaults[row.vault_name].rbac_mode
    }
  }

  acl_vaults_flat = {
    for k, row in local.vaults_flat :
    k => merge(row, { vault_id = local.vault_data[k].id })
    if !local.vault_data[k].rbac_mode
  }

  policy_assignments = merge([
    for vault_key, row in local.acl_vaults_flat : {
      for _, principal in local.principals :
      "${principal.kind}/${vault_key}" => merge(
        row,
        principal,
        {
          secret_permissions = principal.kind == "sp" ? local.sc_secret_permissions : local.sgrp_secret_by_subscription[row.subscription_key]
        },
      )
      if principal.scope_key == row.scope_key
    }
  ]...)
}
