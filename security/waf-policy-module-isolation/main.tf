# One module block per group (don't sweep everything with a single for_each),
# so the -target addresses stay fixed and handy:
#   terraform plan -target='module.sea[0]'     # only SEA's dev + prod
#   terraform plan -target='module.relay[0]'   # only relay's dev + prod

module "sea" {
  source = "./modules/policy_group"
  count  = 1

  group_name = "sea"
  policies   = local.policy_groups.sea
}

module "relay" {
  source = "./modules/policy_group"
  count  = 1

  group_name = "relay"
  policies   = local.policy_groups.relay
}

output "sea_policy_names" {
  value = module.sea[0].policy_names
}

output "relay_policy_names" {
  value = module.relay[0].policy_names
}
