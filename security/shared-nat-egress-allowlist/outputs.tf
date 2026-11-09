output "shared_nat_keys" {
  value = sort(keys(terraform_data.shared_nat_gateway))
}

output "egress_pip_for_allowlist" {
  description = "The NAT PIP to put in the third party's Source IP field (documentation range 198.51.100.0/24)."
  value = {
    for k, row in local.resolved_egress_allowlist :
    k => row.pip_address
  }
}

output "ado_on_shared_nat" {
  description = "NAT keys where include_ado_agent is true (ADO agent subnets, not AKS)."
  value = sort([
    for k, gw in var.shared_nat_gateways :
    k if coalesce(gw.include_ado_agent, false)
  ])
}

output "subnet_keys_by_nat" {
  value = {
    for k, m in terraform_data.shared_nat_gateway :
    k => sort(keys(m.input.subnet_ids))
  }
}

output "duplicate_subnet_attachment" {
  value = local.duplicate_subnet_ids
}
