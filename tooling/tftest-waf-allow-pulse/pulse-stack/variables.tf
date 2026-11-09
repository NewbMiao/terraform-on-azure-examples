variable "custom_rules" {
  description = "WAF custom_rules; path_regression + regression_gate check|test."
  type = list(object({
    name            = string
    action          = string
    operator        = string
    match_values    = list(string)
    regression_gate = optional(string, "check")
    path_regression = optional(object({
      must_match     = list(string)
      must_not_match = list(string)
    }))
  }))
}

variable "test_match_values_override" {
  description = "terraform test negative case: change only the pattern of the regression_gate=test rule."
  type        = map(list(string))
  default     = {}
}
