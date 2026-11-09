# Region group SEA × dev. Default convention: one policy per region per environment.
# This file holds SEA dev's regular services (harbor / pulse); relay sits in its own
# group because its quota is tight.
policy_sea_dev = {
  name    = "policy-sea-dev"
  enabled = true
  mode    = "Prevention"
  managed_rules = [
    {
      type    = "DemoRuleSet"
      version = "1.0"
      action  = "Block"
      exclusions = [
        {
          # harbor: the login session's token refresh rides a cookie
          match_variable = "RequestCookieNames"
          operator       = "Equals"
          selector       = "agentos_refresh_token"
        },
        {
          # pulse: the article body submitted by the editor contains HTML
          match_variable = "RequestBodyJsonArgNames"
          operator       = "Equals"
          selector       = "article_content"
        },
      ]
      overrides = []
    },
  ]
  custom_rules = []
}
