variable "tenants" {
  type = map(object({
    tenant_id    = string
    email_domain = string
  }))
  description = "Tenants allowed to use the portal; the example ids are fictional UUIDs."
}

variable "applications" {
  type = map(object({
    display_name        = string
    redirect_uris       = list(string)
    sign_in_audience    = optional(string, "AzureADMyOrg")
    allowed_tenant_keys = optional(list(string), [])
    patch_restrictions  = optional(bool, false)
  }))
  description = "App registrations maintained by the publisher; only multi-tenant apps with restrictions enabled produce a PATCH."
}
