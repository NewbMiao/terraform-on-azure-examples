# Plays the third-party onboarding registration sheet (egress and inbound in separate columns)

resource "terraform_data" "egress_allowlist_row" {
  for_each = var.egress_allowlist

  input = local.resolved_egress_allowlist[each.key]
}

resource "terraform_data" "inbound_allowlist_row" {
  for_each = var.inbound_allowlist

  input = {
    consumer_label = each.value.consumer_label
    edge_kind      = each.value.edge_kind
    address        = each.value.address
  }
}
