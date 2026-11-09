resource "terraform_data" "aks_cluster" {
  # Azure resource: azurerm_kubernetes_cluster
  input = {
    name             = var.cluster.name
    network_plugin   = "azure"
    network_mode     = "overlay"
    pod_cidr         = var.cluster.pod_cidr
    node_subnet      = var.cluster.node_subnet_name
    node_subnet_cidr = var.cluster.node_subnet_cidr
    node_count       = var.cluster.node_count
    identity         = "SystemAssigned"
    vnet_contributor = "cluster MI on node VNet" # prerequisite for the cloud controller to build the ILB / PLS
  }
}
