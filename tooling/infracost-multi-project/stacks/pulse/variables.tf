variable "environment" {
  type        = string
  description = "dev | prod"
}

variable "pg" {
  type = object({
    sku = string
  })
  description = "PostgreSQL Flexible Server SKU (change sku in the autovar to practice diff)"
}

variable "aca" {
  type = object({
    cpu          = number
    memory_gb    = number
    min_replicas = number
  })
  description = "Main API Container App size"
}

variable "diff" {
  type = object({
    enabled = bool
    worker = object({
      cpu          = number
      memory_gb    = number
      min_replicas = number
    })
    redis = object({
      sku_name = string
      family   = string
      capacity = number
    })
  })
  default = {
    enabled = false
    worker = {
      cpu          = 0.25
      memory_gb    = 0.5
      min_replicas = 1
    }
    redis = {
      sku_name = "Basic"
      family   = "C"
      capacity = 0
    }
  }
  description = "Optional worker ACA + Redis; one enabled flag, default false"
}
