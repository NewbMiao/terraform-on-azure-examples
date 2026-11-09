environment = "prod"

pg = {
  sku = "GP_Standard_D8s_v3"
}

aca = {
  cpu          = 2.0
  memory_gb    = 4.0
  min_replicas = 3
}

diff = {
  enabled = false
  worker = {
    cpu          = 1.0
    memory_gb    = 2.0
    min_replicas = 2
  }
  redis = {
    sku_name = "Standard"
    family   = "C"
    capacity = 1
  }
}
