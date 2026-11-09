# central-lgw-policy-gates

Runnable Terraform example: one org Log Analytics workspace plus two policy gates — DeployIfNotExists for diagnostics, Deny for non-central workspaces — including assignments and existing-resource remediation.

No Azure credentials or subscription needed: Azure resources are played by `terraform_data` and locals, so `terraform plan` expands the full wiring locally.

## Run

```bash
terraform init
terraform plan
```

## Files

| File | Contents |
|------|----------|
| `case.auto.tfvars` | The org LGW and both gates' parameters |
| `variables.tf` | Root variables, `type = any` |
| `lgw.tf` | The org LGW (plays `azurerm_log_analytics_workspace`) and its resource ID |
| `diagnostics_policy.tf` | Gate 1: rule shape, definition, dev/prod assignments (SystemAssigned identity + required role), and remediation (plays `azurerm_policy_definition` / `azurerm_subscription_policy_assignment` / `azurerm_resource_policy_remediation`) |
| `deny_policy.tf` | Gate 2: rule, definition, dev/prod assignments |
| `outputs.tf` | Assignment results and remediation references |

## Check in plan

- `diagnostics_assignments`: one per dev/prod, each with `identity_required_role`
- `deny_assignments`: one per dev/prod, aimed at `Microsoft.OperationalInsights/workspaces`
- `remediation_tasks.policy_assignment_id` references gate 1's assignment, not gate 2's
