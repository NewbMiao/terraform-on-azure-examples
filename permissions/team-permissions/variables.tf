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

variable "teams" {
  description = "Per-team SGRP + dev/prod RG RBAC + team-scoped resource_access (resources in team RGs)."
  type = map(object({
    security_group = object({
      display_name = string
    })
    members = list(string)
    prod_resource_groups = map(object({
      subscription_key = string
      roles            = list(string)
    }))
    dev_resource_groups = map(object({
      subscription_key = string
      roles            = list(string)
    }))
    resource_access = optional(map(object({
      subscription_key    = string
      resource_group_name = string
      resource_name       = string
      resource_type       = string
      roles               = list(string)
      environments        = list(string)
    })), {})
  }))
}

variable "shared_resource_access" {
  description = "Platform-owned resources; per-team SGRP grants (separate from teams.* RG tables)."
  type = map(object({
    subscription_key    = string
    resource_group_name = string
    resource_name       = string
    resource_type       = string
    roles               = list(string)
    teams               = list(string)
  }))
  default = {}
}

variable "acr_scope_tokens" {
  description = "Path-scoped ACR tokens; works without ABAC mode; separate from shared_resource_access."
  type = map(object({
    registry_name = string
    paths = map(object({
      team_key = string
      token    = string
    }))
  }))
  default = {}
}

variable "member_email_domain" {
  type    = string
  default = "example.com"
}
