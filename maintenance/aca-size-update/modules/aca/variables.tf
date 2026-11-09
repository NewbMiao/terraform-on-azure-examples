# Simulates the template/container snapshot read back by data.azapi_resource.live (including pipeline-written fields).
variable "live" {
  type = object({
    image             = string
    env               = list(string)
    secret_names      = list(string)
    probes            = list(string)
    cpu               = number
    memory            = string
    ephemeral_storage = string
  })
}

# Matches the real aca_app: Terraform owns only these four sizing fields.
variable "template_cpu" {
  type = number
}

variable "template_memory" {
  type = string
}

variable "min_replicas" {
  type = number
}

variable "max_replicas" {
  type = number
}

# Mounts owned by this layer; they enter the fingerprint and the PATCH body's volumes / volumeMounts.
variable "volume_mounts" {
  type = list(object({
    name         = string
    mount_path   = string
    storage_type = optional(string, "AzureFile")
    storage_name = string
  }))
  default = []
}
