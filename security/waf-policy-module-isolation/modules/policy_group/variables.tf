variable "group_name" {
  type = string
}

# The complex nested type is defined exactly once, here.
# The root module uses type = any for each region's config; structural validation
# happens when the value arrives here.
# Adding a nested field later means editing this one place, not every regional
# variable in the root module.
variable "policies" {
  type = map(object({
    name    = string
    enabled = bool
    mode    = string
    managed_rules = list(object({
      type    = string
      version = string
      action  = string
      exclusions = optional(list(object({
        match_variable = string
        operator       = string
        selector       = string
      })), [])
      overrides = optional(list(object({
        rule_group_name = string
        rules = optional(list(object({
          rule_id = string
          enabled = optional(bool, true)
          action  = optional(string)
        })), [])
      })), [])
    }))
    custom_rules = optional(list(object({
      name     = string
      priority = number
      action   = string
      match_conditions = list(object({
        match_variable = string
        operator       = string
        match_values   = list(string)
      }))
    })), [])
  }))
}
