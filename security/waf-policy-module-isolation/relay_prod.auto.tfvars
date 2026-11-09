# relay's prod: same shape as dev, but the lists only carry prod-confirmed false positives.
policy_relay_prod = {
  name    = "policy-relay-prod"
  enabled = true
  mode    = "Prevention"
  managed_rules = [
    {
      type       = "DemoRuleSet"
      version    = "1.0"
      action     = "Block"
      exclusions = []
      overrides  = []
    },
  ]
  custom_rules = []
}
