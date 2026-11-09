variable "subscriptions" {
  description = "subscription_key → sub id + label (drives azurerm provider aliases)."
  type = map(object({
    subscription_id = string
    display_name    = string
    purpose         = string
  }))
  default = {
    dev = {
      subscription_id = "11111111-1111-1111-1111-111111111101"
      display_name    = "SUB-EG-APP-DEV"
      purpose         = "dev subscription"
    }
    prod = {
      subscription_id = "22222222-2222-2222-2222-222222222202"
      display_name    = "SUB-EG-APP-PRD"
      purpose         = "production subscription"
    }
  }
}

variable "team_resource_groups" {
  description = "Team RG registry: every deny target must be in this table (the per-team boundary from lesson 1)."
  type = map(object({
    resource_groups = map(object({
      subscription_key = string
      name             = string
    }))
  }))
}

variable "deny_assignments" {
  description = "Shared-account deny registry; phase marks the rollout stage, entries outside active_phases do not land."
  type = map(object({
    subscription_key     = string
    resource_group_name  = string
    deny_assignment_name = string
    users                = list(string)
    actions              = list(string)
    phase                = string # "prod-deny" | "dev-deny"
  }))
}

variable "active_phases" {
  description = "Currently open phases; phase 3 opens prod-deny only, phase 4 adds dev-deny."
  type        = list(string)
}
