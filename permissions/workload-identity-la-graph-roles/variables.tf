variable "graph_api" {
  type = object({
    service_principal_object_id = string
    app_roles                   = map(string)
  })
  description = "Microsoft Graph enterprise application (service principal) and app role id catalog."
}

variable "workloads" {
  type = map(object({
    team_key                       = string
    environment                    = string
    display_name                   = string
    resource_group_name            = string
    location                       = string
    managed_identity_principal_id  = string
    graph_roles                    = list(string)
    use_managed_identity_for_graph = optional(bool, true)
  }))
  description = "Workloads such as Logic Apps; principal_id comes from the system-assigned MI in the real stack."
}

variable "legacy_entra_apps" {
  type = map(object({
    display_name = string
    team_key     = string
    environment  = string
    # The example stores no plaintext secret; it only marks "still depends on a KV reference"
    key_vault_secret_name = string
    graph_roles           = list(string)
    enabled               = optional(bool, false)
  }))
  default     = {}
  description = "For contrast: legacy apps still on client secrets (off by default)."
}
