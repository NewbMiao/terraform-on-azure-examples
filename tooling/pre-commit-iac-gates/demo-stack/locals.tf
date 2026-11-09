locals {
  required_tags = {
    managed_by = "terraform"
    platform   = "eg"
  }

  workloads = {
    for key, workload in var.workloads : key => merge(workload, {
      tags = merge(local.required_tags, workload.tags, {
        environment = workload.environment
      })
    })
  }
}
