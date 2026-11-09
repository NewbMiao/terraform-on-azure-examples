variable "app_apis" {
  description = "Hub app APIs; portal_managed → Portal is authoritative (import / policy / backend body)."
  type = map(object({
    path           = string
    backend_id     = string
    openapi_file   = string
    portal_managed = optional(bool, false)
  }))
  default = {}
}

variable "app_products" {
  description = "Product configuration sheet; api_names drives the product_api links (platform-managed, not ignored)."
  type = map(object({
    api_names = list(string)
  }))
  default = {}
}

variable "apim_api_access" {
  description = "Per-team scoped assignment configuration sheet."
  type = map(object({
    api_names          = optional(list(string), [])
    backend_names      = optional(list(string), [])
    product_names      = optional(list(string), [])
    subscription_names = optional(list(string), [])
    named_value_names  = optional(list(string), [])
    users              = optional(list(string), [])
  }))
  default = {}
}

variable "apim_service_id" {
  description = "Plays the hub APIM ARM id prefix (fictional)."
  type        = string
  default     = "/subscriptions/00000000-0000-0000-0000-000000000011/resourceGroups/RG-EG-HUB-INF/providers/Microsoft.ApiManagement/service/apim-eg-shared"
}
