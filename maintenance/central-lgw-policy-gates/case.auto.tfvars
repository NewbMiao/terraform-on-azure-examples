# Config sheet: the org LGW and the two gates.
# Reading order: start here, then see how the .tf files fold these keys into policy shapes.

subscriptions = {
  dev  = { display_name = "SUB-EG-APP-DEV", id = "8f2c1a00-3b47-4e55-9c11-0a2b3c4d5e01" }
  prod = { display_name = "SUB-EG-APP-PRD", id = "9a3b2c10-4d58-4f66-8d22-1b3c4d5e6f02" }
}

org_lgw = {
  name             = "log-eg-org-sea"
  resource_group   = "RG-EG-HUB-INF"
  subscription_key = "prod"
}

diagnostic_gates = {
  policy_name = "deploy-diagnostics-to-org-lgw"

  # Gate 1 list: when one of these resource types is created, diagnostic settings pointing at the org LGW are added automatically
  covered_resource_types = [
    "Microsoft.App/containerApps",
    "Microsoft.App/jobs",
    "Microsoft.DBforPostgreSQL/flexibleServers",
    "Microsoft.Storage/storageAccounts",
  ]

  # The diagnostics setting name hardcoded in the deploy template — instantly recognizable on the resource page as policy-added
  settings_name = "ds-org-lgw"

  # The role the SystemAssigned identity needs on the target RG; without it deploy gets stopped by RBAC
  identity_role = "Contributor"
}

deny_gates = {
  policy_name          = "deny-log-analytics-workspaces"
  denied_resource_type = "Microsoft.OperationalInsights/workspaces"
  effect               = "Deny"
}
