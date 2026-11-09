# shared-account-deny

Runnable Terraform example: phase-gated deny assignments for a shared deploy account, with every target validated against a team RG registry.

No Azure credentials or subscription needed: Azure resources are played by `terraform_data` and locals, so `terraform plan` expands the full wiring locally.

## Run

```bash
terraform init
terraform plan
```

## Files

| File | Contents |
|------|----------|
| `case.auto.tfvars` | `team_resource_groups`, `deny_assignments`, and `active_phases` sheets |
| `variables.tf` | Input shapes and rollout-phase semantics |
| `providers.tf` | `azurerm.dev` / `azurerm.prod` provider aliases |
| `deny_assignments.tf` | Phase-gated deny assignments, with landing-zone checks |
| `outputs.tf` | Active and pending deny keys, plus mismatch reports |
