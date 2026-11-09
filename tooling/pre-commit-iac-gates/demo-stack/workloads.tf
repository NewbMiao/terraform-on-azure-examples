# Plays azurerm_container_app; the example keeps only the workload shape the gates need to check.
resource "terraform_data" "workload" {
  for_each = local.workloads

  input = {
    name        = each.value.name
    environment = each.value.environment
    sku         = each.value.sku
    replicas    = each.value.replicas
    tags        = each.value.tags
  }
}
