locals {
  shared_nat_subnet_ids = {
    for nat_key, gw in var.shared_nat_gateways : nat_key => merge(
      {
        for sk in gw.subnet_keys :
        sk => var.network_subnet_ids["${gw.vnet_key}/${sk}"]
      },
      coalesce(gw.include_ado_agent, false) ? {
        ado_agent = var.network_subnet_ids["${gw.vnet_key}/ado_agent"]
      } : {},
    )
  }

  subnet_nat_pairs = flatten([
    for nat_key, ids in local.shared_nat_subnet_ids : [
      for sk, subnet_id in ids : {
        subnet_id  = subnet_id
        nat_key    = nat_key
        subnet_key = sk
      }
    ]
  ])

  duplicate_subnet_ids = [
    for subnet_id in distinct([for p in local.subnet_nat_pairs : p.subnet_id]) :
    subnet_id
    if length(distinct([
      for p in local.subnet_nat_pairs : p.nat_key if p.subnet_id == subnet_id
    ])) > 1
  ]

  nat_gateway_key_index = {
    for i, nat_key in sort(keys(var.shared_nat_gateways)) :
    nat_key => i
  }

  catalog_public_ips = {
    for nat_key, gw in var.shared_nat_gateways :
    nat_key => {
      for pip_key, pip in gw.public_ips :
      pip_key => format(
        "198.51.100.%d",
        10 + local.nat_gateway_key_index[nat_key] * 10 + tonumber(pip_key),
      )
    }
  }

  resolved_egress_allowlist = {
    for k, row in var.egress_allowlist :
    k => {
      consumer_label = row.consumer_label
      nat_name       = var.shared_nat_gateways[row.nat_gateway_key].name
      pip_name       = var.shared_nat_gateways[row.nat_gateway_key].public_ips[row.public_ip_key].name
      pip_address    = local.catalog_public_ips[row.nat_gateway_key][row.public_ip_key]
    }
  }
}
