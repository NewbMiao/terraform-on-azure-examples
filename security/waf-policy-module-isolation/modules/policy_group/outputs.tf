output "policy_names" {
  value = { for k, p in var.policies : k => p.name }
}
