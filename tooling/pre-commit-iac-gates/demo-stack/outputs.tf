output "workload_contracts" {
  description = "Normalized workload contracts inspected by terraform test."
  value = {
    for key, workload in terraform_data.workload : key => workload.output
  }
}
