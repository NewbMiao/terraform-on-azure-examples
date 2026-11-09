resource "azurerm_resource_group" "pulse" {
  name     = "RG-PULSE-${upper(var.environment)}-SEA"
  location = "southeastasia"
}

resource "random_password" "pg_admin" {
  length  = 24
  special = true
}

resource "azurerm_postgresql_flexible_server" "pulse" {
  name                   = "pulse-pg-${var.environment}-sea"
  resource_group_name    = azurerm_resource_group.pulse.name
  location               = azurerm_resource_group.pulse.location
  version                = "16"
  administrator_login    = "pulseadmin"
  administrator_password = random_password.pg_admin.result
  storage_mb             = 32768
  sku_name               = var.pg.sku
}

resource "azurerm_container_app_environment" "pulse" {
  name                = "cae-pulse-${var.environment}-sea"
  resource_group_name = azurerm_resource_group.pulse.name
  location            = azurerm_resource_group.pulse.location
}

resource "azurerm_container_app" "api" {
  name                         = "pulse-api-${var.environment}"
  container_app_environment_id = azurerm_container_app_environment.pulse.id
  resource_group_name          = azurerm_resource_group.pulse.name
  revision_mode                = "Single"

  template {
    min_replicas = var.aca.min_replicas

    container {
      name   = "api"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = var.aca.cpu
      memory = "${var.aca.memory_gb}Gi"
    }
  }
}

resource "azurerm_log_analytics_workspace" "pulse" {
  name                = "log-pulse-${var.environment}-sea"
  resource_group_name = azurerm_resource_group.pulse.name
  location            = azurerm_resource_group.pulse.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "pulse" {
  count = 1

  name                = "appi-pulse-${var.environment}-sea"
  resource_group_name = azurerm_resource_group.pulse.name
  location            = azurerm_resource_group.pulse.location
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.pulse.id
}

output "workload_fingerprint" {
  value = {
    pg_sku           = var.pg.sku
    aca_min_replicas = var.aca.min_replicas
    monitored        = length(azurerm_application_insights.pulse) == 1
  }
}
