# outputs expose the key intermediates from the lesson; check both gates against them at plan time.

output "org_lgw_id" {
  description = "Resource ID of the org LGW — where gate 1's deploy template points"
  value       = local.org_lgw_id
}

output "diagnostics_assignments" {
  description = "Gate 1 assignments: one each for dev / prod, with the role the SystemAssigned identity needs"
  value = {
    for key, assignment in terraform_data.diagnostics_assignment :
    key => {
      assignment_id          = local.diagnostics_assignment_ids[key]
      policy_definition_id   = assignment.input.policy_definition_id
      identity_required_role = assignment.input.identity_required_role
    }
  }
}

output "deny_assignments" {
  description = "Gate 2 assignments: one each for dev / prod"
  value = {
    for key, assignment in terraform_data.deny_assignment :
    key => {
      assignment_id        = local.deny_assignment_ids[key]
      policy_definition_id = assignment.input.policy_definition_id
    }
  }
}

output "remediation_tasks" {
  description = "Existing-resource remediation: references gate 1's assignment"
  value = {
    for key, task in terraform_data.diagnostics_remediation :
    key => {
      task_id              = task.input.name
      policy_assignment_id = task.input.policy_assignment_id
    }
  }
}
