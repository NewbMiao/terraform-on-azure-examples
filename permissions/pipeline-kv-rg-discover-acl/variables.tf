variable "access_scopes" {
  description = "Lists the resource groups to cover per team (or scope); vault names are not enumerated."
  type = map(object({
    team_slug            = string
    service_principal_id = optional(string)
    enabled              = optional(bool, true)
    resource_groups = map(object({
      subscription_key = string
      enabled          = optional(bool, true)
    }))
  }))
  default = {}
}

variable "vault_catalog" {
  description = "Plays the data listing result: change vaults to simulate a Key Vault appearing or disappearing in the RG."
  type = map(object({
    resource_group_name = string
    subscription_key    = string
    vaults = map(object({
      rbac_mode = bool
    }))
  }))
  default = {}
}

variable "team_principal_ids" {
  description = "team_slug → Entra group object_id (fake UUIDs in this example)."
  type        = map(string)
  default     = {}
}
