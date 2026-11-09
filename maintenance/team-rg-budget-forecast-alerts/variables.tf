variable "buffer_percent" {
  type        = number
  description = "Headroom above baseline_monthly when computing budget amount (default 20)."
  default     = 20
}

variable "budget_start_date" {
  type        = string
  description = "Monthly budget period start (UTC midnight on 1st)."
  default     = "2026-10-01T00:00:00Z"
}

variable "cloudops_action_group" {
  type = object({
    id   = string
    name = string
  })
}

variable "subscription_id" {
  type        = string
  description = "Env subscription for subscription-scoped cost anomaly alert."
}

variable "anomaly_label" {
  type        = string
  description = "Short token in anomaly alert name (e.g. APP-DEV)."
}

variable "anomaly_display_name" {
  type        = string
  description = "Subscription display name in anomaly email subject."
}

variable "cloudops_emails" {
  type        = list(string)
  description = "Direct recipients for subscription cost anomaly (RG budget uses action group)."
}

# RG name → typical monthly cost (USD); optional extra recipients (beyond the action group)
variable "resource_groups" {
  type = map(object({
    baseline_monthly = number
    contact_emails   = optional(list(string), [])
  }))
}
