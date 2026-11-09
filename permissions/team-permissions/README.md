# team-permissions

Runnable Terraform example: per-team Entra groups, RG-scoped RBAC, single-resource grants, and shared-ACR access for three fictional teams.

No Azure credentials or subscription needed: Azure resources are played by `terraform_data` and locals, so `terraform plan` expands the full wiring locally.

## Run

```bash
terraform init
terraform plan
```

## Files

| File | Contents |
|------|----------|
| `case.auto.tfvars` | Three teams' `teams` sheets, plus `shared_resource_access` |
| `subscriptions.tf` | `subscription_key` → subscription ID / display name |
| `providers.tf` | `azurerm.dev` / `azurerm.prod` provider aliases |
| `members.tf` | SGRP membership |
| `team_rg_rbac.tf` | Per-team RG role assignments for dev / prod |
| `resource_access.tf` | Single-resource grants |
| `shared_resource_access.tf` | Shared ACR team grants |
| `acr_scope_tokens.tf` | Per-path ACR scope tokens |

## More

The story, the wrong turns, and the design reasoning behind this example are in the book: <https://leanpub.com/terraform-on-azure>
