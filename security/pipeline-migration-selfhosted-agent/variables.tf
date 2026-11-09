variable "ado_agent" {
  description = "Platform ADO agent subnet registration; db_destination_prefixes must pair with the pe_db inbound allowlist."
  type = object({
    subnet_name                 = string
    address_prefix              = string
    db_destination_prefixes     = list(string)
    db_ports                    = list(string)
    hub_pe_destination_prefixes = optional(list(string), [])
  })
}

variable "pe_db" {
  description = "The shared DB Private Endpoint subnet."
  type = object({
    subnet_name    = string
    address_prefix = string
  })
}

variable "pe_db_inbound_db_sources" {
  description = "pe_db inbound 5432 sources: keys are registration names, values are source CIDRs (including the team ACA and ADO subnets)."
  type        = map(string)
}

variable "ado_elastic_pool" {
  description = "The org Linux VMSS + azuredevops_elastic_pool; the pool name matches the VMSS, and the pipeline job's pool uses name."
  type = object({
    name                  = string
    vmss_name             = string
    service_endpoint_name = string
    desired_idle          = number
    max_capacity          = number
  })
}
