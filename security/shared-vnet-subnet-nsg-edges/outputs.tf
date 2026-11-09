output "vnet_keys" {
  value = sort(keys(var.virtual_networks))
}

output "subnet_keys_by_vnet" {
  value = {
    for vnet_key, vnet in var.virtual_networks :
    vnet_key => sort([for sk, _ in vnet.subnets : sk])
  }
}

output "nsg_rule_keys" {
  value = sort(keys(terraform_data.nsg_rule))
}

output "deny_vnet_rule_keys" {
  description = "Deny outbound rules between team ACAs (one per subnet pair)."
  value = sort([
    for k, _ in terraform_data.nsg_rule :
    k
    if can(regex("/out/deny-vnet/", k))
  ])
}

output "dev_sea_relay_to_pe_db" {
  description = "Whether dev SEA relay ACA outbound 5432 is registered with pe_db."
  value       = try(terraform_data.nsg_rule["dev_sea_01/aca_relay_dev/out/pe_db/5432"].input, null)
}

output "aca_subnet_roles" {
  value = {
    for k, row in terraform_data.subnet :
    k => row.input.role
    if row.input.role == "aca"
  }
}
