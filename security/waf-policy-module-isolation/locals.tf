locals {
  # First collect the configs from the files into one map, then split by group.
  # Real type validation happens when the values are passed into the child module.
  policy_inputs = {
    "sea-dev"    = var.policy_sea_dev
    "sea-prod"   = var.policy_sea_prod
    "relay-dev"  = var.policy_relay_dev
    "relay-prod" = var.policy_relay_prod
  }

  # Each group maps to one module block in main.tf (module.sea / module.relay).
  # sea is region-scoped, relay is app-scoped; neither references the other.
  policy_group_keys = {
    sea   = ["sea-dev", "sea-prod"]
    relay = ["relay-dev", "relay-prod"]
  }

  # Split by group; each module receives only its own group.
  policy_groups = {
    for group, keys in local.policy_group_keys : group => {
      for k in keys : k => local.policy_inputs[k]
    }
  }
}
