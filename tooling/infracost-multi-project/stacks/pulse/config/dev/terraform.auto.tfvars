environment = "dev"

pg = {
  sku = "GP_Standard_D2s_v3"
}

aca = {
  cpu          = 0.5
  memory_gb    = 1.0
  min_replicas = 1
}

diff = {
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

# Practicing diff: change pg / aca, or set diff.enabled = true (worker + redis appear together)
# pg = { sku = "GP_Standard_D4s_v3" }
# diff = { enabled = true, worker = { ... }, redis = { sku_name = "Standard", family = "C", capacity = 1 } }
