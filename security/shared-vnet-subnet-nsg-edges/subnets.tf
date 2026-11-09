locals {
  subnet_role = {
    for k, row in local.subnets_flat :
    k => (
      startswith(row.subnet_key, "aca_") ? "aca" :
      startswith(row.subnet_key, "pe_db_") ? "pe_db" :
      startswith(row.subnet_key, "pe_") ? "pe" :
      "other"
    )
  }

  subnets_flat = merge([
    for vnet_key, vnet in var.virtual_networks : {
      for subnet_key, subnet in vnet.subnets :
      "${vnet_key}/${subnet_key}" => merge(subnet, {
        vnet_key         = vnet_key
        subnet_key       = subnet_key
        vnet_name        = vnet.name
        location         = vnet.location
        subscription_key = vnet.subscription_key
      })
    }
  ]...)
}

resource "terraform_data" "subnet" {
  for_each = local.subnets_flat

  input = {
    azure_resource   = "azurerm_subnet"
    vnet_key         = each.value.vnet_key
    vnet_name        = each.value.vnet_name
    subnet_key       = each.value.subnet_key
    name             = each.value.name
    address_prefixes = each.value.address_prefixes
    role             = local.subnet_role[each.key]
    delegation       = try(each.value.delegation, null)
  }
}
