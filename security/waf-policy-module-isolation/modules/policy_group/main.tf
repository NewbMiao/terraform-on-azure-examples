# terraform_data stands in for the real cloud resource here (e.g. a firewall policy).
# This lesson doesn't talk to Azure; the point is whether the data structure passed in holds up.
resource "terraform_data" "policy" {
  for_each = var.policies

  input = {
    group         = var.group_name
    key           = each.key
    name          = each.value.name
    mode          = each.value.mode
    managed_rules = each.value.managed_rules
    custom_rules  = each.value.custom_rules
  }
}
