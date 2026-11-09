output "logic_app_principal_ids" {
  description = "The MI principal per workload (matches the graph assignment's principal_object_id)."
  value = {
    for k, w in var.workloads : k => w.managed_identity_principal_id
  }
}

output "graph_role_assignment_keys" {
  description = "Keys of the Graph app role assignments on the LA MI (workload:role)."
  value       = sort(keys(local.graph_role_assignments))
}

output "legacy_path_enabled" {
  description = "Whether the legacy client-secret contrast block is enabled (default false)."
  value       = length(local.legacy_graph_role_assignments) > 0
}
