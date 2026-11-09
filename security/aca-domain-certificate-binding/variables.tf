variable "aca" {
  type = object({
    app_name              = string
    origin_hostname       = string
    public_network_access = string
    custom_domain = optional(object({
      hostname                  = string
      certificate_name          = string
      domain_control_validation = string
    }))
  })
}

