variable "admin_password_version" {
  type        = number
  description = "Rotation gate: bump it when the password regenerates, and the server writes the new value."
  default     = 0
}

variable "administrator_login" {
  type    = string
  default = "relaydevadmin"
}

variable "server" {
  type = object({
    name = string
  })
  description = "Name of the existing PostgreSQL Flexible Server."
}

variable "app" {
  type = object({
    display_name = string
    client_id    = string
    object_id    = string
  })
  description = "The Entra app already imported into state; object_id is the segment used as application_id in the password instance."
}

variable "portal_credential" {
  type = object({
    key_id       = string
    start_date   = string
    end_date     = string
    display_name = optional(string, "terraform-managed")
  })
  description = "Metadata of the portal-created client secret; keyId and start/end times are readable from Graph."
}

variable "client_secret" {
  type        = string
  description = "Plaintext of the portal-created secret — local input only, never committed."
  sensitive   = true
}

# The same value sits in several KV copies; source says which source each copy follows.
variable "key_vault_secrets" {
  type = map(object({
    vault        = string
    secret_name  = string
    source       = string
    content_type = optional(string, "application/x-password")
  }))
  description = "Copy sheet: vault is the KV short name, source is pg or entra."
}
