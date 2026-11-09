# Plays the platform NET module: NAT Gateway + public IPs + subnet associations
# (ACA subnet_keys + optional ADO agent subnet)

resource "terraform_data" "shared_nat_gateway" {
  for_each = var.shared_nat_gateways

  input = {
    subscription_key    = each.value.subscription_key
    vnet_key            = each.value.vnet_key
    resource_group_name = each.value.resource_group_name
    location            = each.value.location
    name                = each.value.name
    public_ips          = each.value.public_ips
    subnet_keys         = each.value.subnet_keys
    include_ado_agent   = coalesce(each.value.include_ado_agent, false)
    subnet_ids          = local.shared_nat_subnet_ids[each.key]
    egress_public_ips   = local.catalog_public_ips[each.key]
  }

  lifecycle {
    precondition {
      condition     = length(local.duplicate_subnet_ids) == 0
      error_message = "A subnet cannot be attached to two NAT gateways; conflicting subnet IDs: ${join(", ", local.duplicate_subnet_ids)}"
    }
  }
}
