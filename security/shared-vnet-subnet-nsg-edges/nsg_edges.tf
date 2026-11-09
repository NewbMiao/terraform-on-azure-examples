locals {
  vnet_layout = {
    for vnet_key, vnet in var.virtual_networks :
    vnet_key => {
      aca_keys = [
        for sk, _ in vnet.subnets :
        "${vnet_key}/${sk}"
        if startswith(sk, "aca_")
      ]
      pe_db_key = one([
        for sk, _ in vnet.subnets :
        "${vnet_key}/${sk}"
        if startswith(sk, "pe_db_")
      ])
      pe_key = one([
        for sk, _ in vnet.subnets :
        "${vnet_key}/${sk}"
        if startswith(sk, "pe_") && !startswith(sk, "pe_db_")
      ])
    }
  }

  nsg_rules = merge(
    merge([
      for vnet_key, layout in local.vnet_layout : merge([
        for aca_key in layout.aca_keys : {
          "${aca_key}/in/AzureLoadBalancer" = {
            vnet_key          = vnet_key
            subnet_key        = local.subnets_flat[aca_key].subnet_key
            direction         = "Inbound"
            access            = "Allow"
            priority          = 100
            source_address    = "AzureLoadBalancer"
            destination_cidr  = local.subnets_flat[aca_key].address_prefixes[0]
            destination_ports = "30000-32767"
            note              = "Front Door / ACA ingress health"
          }
        }
      ]...)
    ]...),
    merge([
      for vnet_key, layout in local.vnet_layout : merge([
        for aca_key in layout.aca_keys : {
          "${aca_key}/out/pe_db/5432" = {
            vnet_key          = vnet_key
            subnet_key        = local.subnets_flat[aca_key].subnet_key
            direction         = "Outbound"
            access            = "Allow"
            priority          = 200
            source_cidr       = local.subnets_flat[aca_key].address_prefixes[0]
            destination_cidr  = local.subnets_flat[layout.pe_db_key].address_prefixes[0]
            destination_ports = "5432"
            note              = "ACA to DB PE NIC"
          }
          "${aca_key}/out/pe/443" = {
            vnet_key          = vnet_key
            subnet_key        = local.subnets_flat[aca_key].subnet_key
            direction         = "Outbound"
            access            = "Allow"
            priority          = 210
            source_cidr       = local.subnets_flat[aca_key].address_prefixes[0]
            destination_cidr  = local.subnets_flat[layout.pe_key].address_prefixes[0]
            destination_ports = "443"
            note              = "ACA to shared PE (Redis/Blob/KV)"
          }
        }
      ]...)
    ]...),
    merge([
      for vnet_key, layout in local.vnet_layout : merge([
        for aca_key in layout.aca_keys : {
          for other_key in layout.aca_keys :
          "${aca_key}/out/deny-vnet/${local.subnets_flat[other_key].subnet_key}" => {
            vnet_key          = vnet_key
            subnet_key        = local.subnets_flat[aca_key].subnet_key
            direction         = "Outbound"
            access            = "Deny"
            priority          = 4096
            source_cidr       = local.subnets_flat[aca_key].address_prefixes[0]
            destination_cidr  = local.subnets_flat[other_key].address_prefixes[0]
            destination_ports = "*"
            note              = "Deny VirtualNetwork between team ACA subnets"
          }
          if other_key != aca_key
        }
      ]...)
    ]...),
    merge([
      for vnet_key, layout in local.vnet_layout : merge([
        for aca_key in layout.aca_keys : {
          "${layout.pe_db_key}/in/${local.subnets_flat[aca_key].subnet_key}/5432" = {
            vnet_key          = vnet_key
            subnet_key        = local.subnets_flat[layout.pe_db_key].subnet_key
            direction         = "Inbound"
            access            = "Allow"
            priority          = 200
            source_cidr       = local.subnets_flat[aca_key].address_prefixes[0]
            destination_cidr  = local.subnets_flat[layout.pe_db_key].address_prefixes[0]
            destination_ports = "5432"
            note              = "pe_db accepts team ACA only"
          }
        }
      ]...)
    ]...),
  )
}

resource "terraform_data" "nsg_rule" {
  for_each = local.nsg_rules

  input = merge(each.value, {
    azure_resource = "azurerm_network_security_rule"
    rule_key       = each.key
  })
}
