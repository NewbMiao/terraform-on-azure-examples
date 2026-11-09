# diff.enabled = true creates worker + Redis; SKUs live in var.diff.worker / var.diff.redis.

resource "azurerm_container_app" "worker" {
  count = var.diff.enabled ? 1 : 0

  name                         = "pulse-worker-${var.environment}"
  container_app_environment_id = azurerm_container_app_environment.pulse.id
  resource_group_name          = azurerm_resource_group.pulse.name
  revision_mode                = "Single"

  template {
    min_replicas = var.diff.worker.min_replicas

    container {
      name   = "worker"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = var.diff.worker.cpu
      memory = "${var.diff.worker.memory_gb}Gi"
    }
  }
}

resource "azurerm_redis_cache" "pulse" {
  count = var.diff.enabled ? 1 : 0

  name                = "redis-pulse-${var.environment}-sea"
  location            = azurerm_resource_group.pulse.location
  resource_group_name = azurerm_resource_group.pulse.name
  capacity            = var.diff.redis.capacity
  family              = var.diff.redis.family
  sku_name            = var.diff.redis.sku_name
  minimum_tls_version = "1.2"
}
