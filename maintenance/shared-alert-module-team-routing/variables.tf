# Platform side: team recipient catalog (real implementation: azurerm_monitor_action_group + team_action_groups tfvars)
variable "team_action_groups" {
  type = map(object({
    email_addresses     = optional(list(string), [])
    security_group_name = optional(string)
  }))
  description = "One row per team; email or SGRP, pick one (the example uses email)."
}

variable "cloudops_action_group" {
  type = object({
    name = string
  })
  default = {
    name = "ag-cloudops"
  }
}

# Team side: aca_alerts module input shape (real implementation is the shared aca_alerts module)
variable "aca_alerts" {
  type = map(object({
    resource_groups = list(string)
    severity        = optional(number)
    action_group = optional(object({
      team_key         = optional(string)
      include_cloudops = optional(bool, true)
    }), {})
    rules = optional(object({
      job_startup_failure = optional(object({
        enabled   = optional(bool, true)
        threshold = optional(number, 0)
      }), {})
      app_startup_failure = optional(object({
        enabled   = optional(bool, true)
        threshold = optional(number, 0)
      }), {})
      app_restart = optional(object({
        enabled        = optional(bool, false)
        threshold      = optional(number, 4)
        window_minutes = optional(number, 15)
      }), {})
      app_memory_high = optional(object({
        enabled           = optional(bool, false)
        threshold_percent = optional(number, 90)
        window_minutes    = optional(number, 15)
        aggregation       = optional(string, "Average")
      }), {})
      app_cpu_high = optional(object({
        enabled           = optional(bool, false)
        threshold_percent = optional(number, 95)
        window_minutes    = optional(number, 15)
        aggregation       = optional(string, "Maximum")
      }), {})
      pg_restart = optional(object({
        enabled        = optional(bool, false)
        window_minutes = optional(number, 5)
      }), {})
    }))
  }))
}

variable "org_log_analytics_workspace_id" {
  type        = string
  description = "Org LGW resource ID; both ACA and PG rule scopes point at it."
  default     = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/RG-EG-HUB-MON-SEA/providers/Microsoft.OperationalInsights/workspaces/lgw-eg-org"
}
