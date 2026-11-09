# Gate 1: DeployIfNotExists — listed resource types get wired to the org LGW automatically

locals {
  # Shape of the gate-1 policy rule: when a listed type lacks diagnostic settings,
  # the deployment is the ARM template that patches it. To check whether it landed, glance at the Portal resource page.
  diagnostics_policy_rule = {
    if = {
      field = "type"
      in    = var.diagnostic_gates.covered_resource_types
    }
    then = {
      effect = "DeployIfNotExists"
      details = {
        type            = "Microsoft.Insights/diagnosticSettings"
        evaluationDelay = "AfterProvisioning"
        name            = var.diagnostic_gates.settings_name
        deployment = {
          properties = {
            mode = "incremental"
            template = {
              resources = [{
                type       = "Microsoft.Insights/diagnosticSettings"
                apiVersion = "2021-05-01-preview"
                name       = var.diagnostic_gates.settings_name
                properties = {
                  workspaceId = local.org_lgw_id
                  # Real templates list logs / metrics categories per resource type; omitted here
                }
              }]
            }
          }
        }
      }
    }
  }

  # ID shapes for the policy / assignments (real repos use the resources' own ids; here we assemble them from names)
  diagnostics_definition_id = format(
    "/providers/Microsoft.Authorization/policyDefinitions/%s",
    var.diagnostic_gates.policy_name,
  )
  diagnostics_assignment_ids = {
    for key, sub in var.subscriptions :
    key => format(
      "/subscriptions/%s/providers/Microsoft.Authorization/policyAssignments/%s-%s",
      sub.id, var.diagnostic_gates.policy_name, key,
    )
  }
}

# Plays: azurerm_policy_definition (gate 1)
resource "terraform_data" "diagnostics_policy" {
  input = {
    name             = var.diagnostic_gates.policy_name
    policy_type      = "Custom"
    mode             = "Indexed"
    policy_rule_json = jsonencode(local.diagnostics_policy_rule)
  }
}

# Plays: azurerm_subscription_policy_assignment — one each for dev / prod
resource "terraform_data" "diagnostics_assignment" {
  for_each = var.subscriptions

  input = {
    name                 = format("%s-%s", var.diagnostic_gates.policy_name, each.key)
    subscription_id      = format("/subscriptions/%s", each.value.id)
    policy_definition_id = local.diagnostics_definition_id

    # SystemAssigned identity: the deploy template uses it to create diagnostic settings on the target RG
    identity = { type = "SystemAssigned" }
    # The role this identity needs on the target RG; without it deploy gets stopped by RBAC
    identity_required_role = var.diagnostic_gates.identity_role
  }
}

# Plays: azurerm_resource_policy_remediation — one pass over existing resources (gate 1 doesn't retro-fit on its own)
resource "terraform_data" "diagnostics_remediation" {
  for_each = var.subscriptions

  input = {
    name                 = format("remediate-%s-%s", var.diagnostic_gates.policy_name, each.key)
    scope                = format("/subscriptions/%s", each.value.id)
    policy_assignment_id = local.diagnostics_assignment_ids[each.key]
  }
}
