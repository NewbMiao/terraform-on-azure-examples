# HTTP trigger: SAS disabled, Entra Bearer only; validates iss / aud / appid claims.
locals {
  logic_app_oauth_issuer = "https://sts.windows.net/${var.tenant_id}/"

  logic_app_oauth_base_claims = [
    { name = "iss", value = local.logic_app_oauth_issuer },
    { name = "aud", value = var.logic_app.oauth_audience },
  ]

  logic_app_oauth_policies = length(var.logic_app.caller_apps) > 0 ? {
    for policy_name, client_id in var.logic_app.caller_apps : policy_name => {
      type = "AAD"
      claims = concat(local.logic_app_oauth_base_claims, [
        { name = "appid", value = client_id },
      ])
    }
    } : {
    tenant-oauth = {
      type   = "AAD"
      claims = local.logic_app_oauth_base_claims
    }
  }

  logic_app_catalog = {
    version = 1
    apps = {
      for app_key, app in var.logic_app.apps : app_key => {
        display_name  = app.display_name
        approver_upns = app.approver_upns
      }
    }
    groups = {
      for group_name, row in var.logic_app.groups : group_name => {
        group_object_id = row.group_object_id
        allowed_apps    = row.allowed_apps
        allow_remove    = coalesce(row.allow_remove, true)
      }
    }
  }
}

# Real resource: azurerm_logic_app_workflow / azapi_resource Microsoft.Logic/workflows
resource "terraform_data" "logic_app_workflow" {
  input = {
    azure_resource = "azurerm_logic_app_workflow"
    name           = var.logic_app.name

    access_control_triggers = {
      sasAuthenticationPolicy = {
        state = "Disabled"
      }
      openAuthenticationPolicies = {
        policies = local.logic_app_oauth_policies
      }
    }

    definition_parameters = {
      catalog = {
        type         = "Object"
        defaultValue = local.logic_app_catalog
      }
    }

    workflow_runtime_checks = [
      "triggerBody group must exist in catalog.groups",
      "triggerBody app must be in catalog.groups[group].allowed_apps",
      "targets resolved to object_id before Graph group member add/remove",
    ]

    approval_required = var.logic_app.approval_required
    supports_batch    = var.logic_app.supports_batch
    callback_enabled  = var.logic_app.callback_enabled
    graph_operation   = "add/remove group members (Logic App managed identity / Graph app permission)"
  }
}

# A caller trades a client secret or certificate for a token, then POSTs the trigger; the token must satisfy the iss/aud/appid claims in the policies above.
resource "terraform_data" "logic_app_caller_token" {
  for_each = var.logic_app.caller_apps

  input = {
    caller_policy_name = each.key
    client_id          = each.value
    token_endpoint     = "https://login.microsoftonline.com/${var.tenant_id}/oauth2/v2.0/token"
    scope              = "${var.logic_app.oauth_audience}/.default"
    required_claims    = local.logic_app_oauth_policies[each.key].claims
  }
}
