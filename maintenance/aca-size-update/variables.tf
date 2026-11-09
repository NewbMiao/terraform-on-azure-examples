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

variable "volume_mounts" {
  type = list(object({
    name         = string
    mount_path   = string
    storage_type = optional(string, "AzureFile")
    storage_name = string
  }))
  default = []
}
