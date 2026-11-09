variable "virtual_networks" {
  description = "Shape of the platform network stack's virtual_networks; subnet keys aca_* / pe_db_* / pe_*."
  type = map(object({
    name             = string
    location         = string
    address_space    = list(string)
    subscription_key = string
    subnets = map(object({
      name             = string
      address_prefixes = list(string)
      delegation = optional(object({
        name         = string
        service_name = string
        actions      = list(string)
      }))
    }))
  }))
  default = {}
}
