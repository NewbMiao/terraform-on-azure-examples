variable "tenant_id" {
  description = "Fictional tenant ID, used only to shape the Logic App trigger's iss claim."
  type        = string
}

variable "nest_sources" {
  description = "Nest source catalog: group name → member UPNs. Enterprise applications don't expand nesting, so Terraform expands them into direct members."
  type        = map(list(string))
}

variable "applications" {
  description = "App configuration sheet: one SSO group per App, plus which nest sources it accepts."
  type = map(object({
    display_name                 = string
    app_role_assignment_required = bool
    sso_group_name               = string
    nested_groups                = optional(list(string), [])
    members                      = optional(list(string), []) # exception belonging to no source
    group_membership_claims      = optional(list(string), [])
  }))
}

variable "user_object_ids" {
  description = "Verified UPN → object_id cache; keys are lowercase UPNs, matching the lookup."
  type        = map(string)
  default     = {}
}

variable "logic_app" {
  description = "Logic App approval-based group adds: trigger Entra OAuth + a catalog, workflow actions not expanded."
  type = object({
    name              = string
    oauth_audience    = optional(string, "https://management.azure.com/")
    caller_apps       = optional(map(string), {}) # policy name → Entra app (client) ID, matching the trigger claim appid
    approval_required = bool
    supports_batch    = bool
    callback_enabled  = bool
    apps = map(object({
      display_name  = string
      approver_upns = list(string)
    }))
    groups = map(object({
      group_object_id = string
      allowed_apps    = list(string)
      allow_remove    = optional(bool, true)
    }))
  })
}
