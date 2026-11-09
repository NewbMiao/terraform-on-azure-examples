variable "subscriptions" {
  description = "subscription_key → sub id + label (drives azurerm provider aliases)."
  type = map(object({
    subscription_id = string
    display_name    = string
  }))
  default = {
    dev = {
      subscription_id = "11111111-1111-1111-1111-111111111101"
      display_name    = "SUB-EG-APP-DEV"
    }
    prod = {
      subscription_id = "22222222-2222-2222-2222-222222222202"
      display_name    = "SUB-EG-APP-PRD"
    }
  }
}

variable "project" {
  type = object({
    name = string
  })
}

# Azure: team SGRP + team RGs (members live in the Entra SGRP, not in this table)
variable "teams" {
  type = map(object({
    security_group = object({
      display_name = string
      object_id    = string
    })
    resource_groups = map(object({
      subscription_key = string
      name             = string
    }))
  }))
}

# ADO: per-team allowlist (in production split into tables: ado_team_access + ado_team_service_connection_access + pipeline_folders + library_resources)
variable "team_ado" {
  type = map(object({
    service_connection_names = list(string)
    pipeline_path            = string
    library = object({
      variable_groups = optional(map(number), {}) # VG name → ADO numeric id (no bulk list API, so a catalog is maintained)
      environments    = optional(map(number), {}) # deployment environment name → id
    })
    git_repositories = optional(map(object({
      deny_other_teams = optional(bool, true) # other teams' ADO groups get Deny on this repo (same idea as pipeline folder isolation)
    })), {})
  }))
}

variable "legacy_subscription_service_connections" {
  description = "For contrast — before the switch, one subscription-scoped ARM SC each for dev/prd (same names as the lesson's Comparison section)"
  type = map(object({
    name             = string
    subscription_key = string
    deploy_identity  = string
  }))
  default = {}
}

variable "shared_acr_name" {
  type    = string
  default = "acreg"
}
