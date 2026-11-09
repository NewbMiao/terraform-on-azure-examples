variable "private_link_dns" {
  description = "Config sheet: logical record name, zone, surviving PE private IP, and the zone's current A record IPs (checked against the precondition at plan time)."
  type = map(object({
    record_name   = string
    zone_name     = string
    pe_private_ip = string
    dns_a_records = list(string)
  }))
}

variable "storage_pe" {
  description = "Config sheet: the team stack's storage_pe module input shape (fictional names, no Azure calls)."
  type = map(object({
    environment            = string
    account_name           = string
    account_resource_group = string
    subresource_names      = list(string)
    network = object({
      resource_group_name = string
      vnet_name           = string
      subnet_name         = string
    })
    private_dns = object({
      zone_name                = string
      zone_resource_group_name = string
      create_zone              = bool
      verify_a_record          = bool
      vnet_links = list(object({
        name                     = string
        vnet_resource_group_name = string
        vnet_name                = string
      }))
    })
  }))
  default = {}
}
