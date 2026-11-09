# The same region's prod, kept as an independent config; no need to open this
# file when changing dev.
# custom_rules is omitted — the child module supplies a default, and that one
# place decides how loose it gets.
policy_sea_prod = {
  name    = "policy-sea-prod"
  enabled = true
  mode    = "Prevention"
  managed_rules = [
    {
      type    = "DemoRuleSet"
      version = "1.0"
      action  = "Block"
      exclusions = [
        {
          match_variable = "RequestCookieNames"
          operator       = "Equals"
          selector       = "agentos_refresh_token"
        },
      ]
      overrides = []
    },
  ]
}
