# App group relay × dev. Exclusions are many and change often, so it's split out
# from the regional file.
# Each policy's quota is counted independently: exclusions here don't take up
# sea_dev's slots.
policy_relay_dev = {
  name    = "policy-relay-dev"
  enabled = true
  mode    = "Prevention"
  managed_rules = [
    {
      type    = "DemoRuleSet"
      version = "1.0"
      action  = "Block"
      exclusions = [
        {
          # The note field in the request body trips the rule
          match_variable = "RequestBodyJsonArgNames"
          operator       = "Equals"
          selector       = "payload.note"
        },
      ]
      overrides = [
        {
          # Not yet confirmed as a real false positive — drop to Log and watch
          rule_group_name = "DEMO-SQLI"
          rules = [
            {
              rule_id = "942100"
              action  = "Log"
            },
          ]
        },
      ]
    },
  ]
  custom_rules = [
    {
      # Allow the whole path segment: requests outside the path are still inspected
      name     = "AllowRelayPath"
      priority = 10
      action   = "Allow"
      match_conditions = [
        {
          match_variable = "RequestUri"
          operator       = "RegEx"
          match_values   = ["^[^?]*/relay/api/(chat|preview)(/|\\?|$)"]
        },
      ]
    },
  ]
}
