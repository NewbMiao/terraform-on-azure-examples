variable "workloads" {
  description = "Workloads checked by the local Git gates."
  type = map(object({
    name        = string
    environment = string
    sku         = string
    replicas    = number
    tags        = optional(map(string), {})
  }))
}
