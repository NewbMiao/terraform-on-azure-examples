run "workload_contract" {
  command = plan

  assert {
    condition = alltrue([
      for workload in local.workloads :
      contains(["dev", "prod"], workload.environment)
    ])
    error_message = "Every workload must use the dev or prod environment."
  }

  assert {
    condition = alltrue([
      for workload in local.workloads :
      workload.replicas > 0 && workload.tags["managed_by"] == "terraform"
    ])
    error_message = "Every workload needs at least one replica and the managed_by tag."
  }
}
