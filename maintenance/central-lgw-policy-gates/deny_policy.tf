# Gate 2: Deny — no new LGWs in the subscription, one clean cut; logging scenarios don't need exceptions

locals {
  deny_policy_rule = {
    if   = { field = "type", equals = var.deny_gates.denied_resource_type }
    then = { effect = var.deny_gates.effect }
  }

  deny_definition_id = format(
    "/providers/Microsoft.Authorization/policyDefinitions/%s",
    var.deny_gates.policy_name,
  )
  deny_assignment_ids = {
    for key, sub in var.subscriptions :
    key => format(
      "/subscriptions/%s/providers/Microsoft.Authorization/policyAssignments/%s-%s",
      sub.id, var.deny_gates.policy_name, key,
    )
  }
}

# Plays: azurerm_policy_definition (gate 2)
resource "terraform_data" "deny_policy" {
  input = {
    name             = var.deny_gates.policy_name
    policy_type      = "Custom"
    mode             = "Indexed"
    policy_rule_json = jsonencode(local.deny_policy_rule)
  }
}

# Plays: azurerm_subscription_policy_assignment — one each for dev / prod
resource "terraform_data" "deny_assignment" {
  for_each = var.subscriptions

  input = {
    name                 = format("%s-%s", var.deny_gates.policy_name, each.key)
    subscription_id      = format("/subscriptions/%s", each.value.id)
    policy_definition_id = local.deny_definition_id
  }
}
