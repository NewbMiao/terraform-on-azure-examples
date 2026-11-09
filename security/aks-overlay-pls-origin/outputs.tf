output "network" {
  value = {
    pod_cidr       = terraform_data.aks_cluster.output.pod_cidr
    node_subnet    = terraform_data.aks_cluster.output.node_subnet
    nsg_rule_count = length(terraform_data.nsg_rule)
  }
}

output "edge" {
  value = {
    pls    = terraform_data.pls_ingress.output
    domain = terraform_data.waf_custom_domain.output
    origin = terraform_data.waf_origin.output
    route  = terraform_data.waf_route.output
  }
}
