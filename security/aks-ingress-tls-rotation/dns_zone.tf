resource "terraform_data" "dns_zone" {
  # Azure resource: azurerm_dns_zone (the child zone holding the certificates)
  for_each = local.zone_layout

  input = {
    name                = each.key
    resource_group_name = var.tls.dns.resource_group_name
    note                = "the issuer writes only this zone and leaves the parent zone's other records alone"
  }
}

resource "terraform_data" "dns_delegation" {
  # Azure resource: azurerm_dns_ns_record (handing the child zone over from the parent zone)
  for_each = local.zone_layout

  input = {
    name                = each.value.delegation_label
    zone_name           = each.value.parent_zone
    resource_group_name = var.tls.dns.resource_group_name
    ttl                 = 3600
    records             = "the child zone's four NS records"
  }

  depends_on = [terraform_data.dns_zone]
}

resource "terraform_data" "dns_zone_grant" {
  # Azure resource: azurerm_role_assignment (DNS Zone Contributor, scope pinned to the child zone)
  # This grant exists only for DNS-01: the old path (certificates from KV) needs no DNS write access at all
  for_each = var.cert_manager.enabled ? local.zone_layout : {}

  input = {
    scope                = "${var.tls.dns.resource_group_name}/${each.key}"
    role_definition_name = "DNS Zone Contributor"
    principal            = terraform_data.dns_identity[0].output.name
    environments         = each.value.environments
  }

  depends_on = [terraform_data.dns_identity]
}
