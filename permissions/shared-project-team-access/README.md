# shared-project-team-access

Runnable Terraform example: per-team ADO service connections scoped to team resource groups, plus Library, pipeline-folder, and repository isolation across teams.

No Azure credentials or subscription needed: Azure resources are played by `terraform_data` and locals, so `terraform plan` expands the full wiring locally.

## Run

```bash
terraform init
terraform plan
```

## Files

| File | Contents |
|------|----------|
| `case.auto.tfvars` | `teams` (Azure) and `team_ado` (ADO allowlist) sheets |
| `variables.tf` | Input shapes, including the legacy subscription-scoped SC contrast |
| `providers.tf` | `azurerm.dev` / `azurerm.prod` provider aliases |
| `project.tf` | The ADO project and team SGRP stand-ins |
| `locals.tf` | Shared lookups and the KV-linked variable-group metadata |
| `service_connections.tf` | Per-team, per-environment ARM connections (WIF) scoped to team RGs |
| `legacy_shared_service_connections.tf` | The old subscription-scoped shared connections, for contrast |
| `azure_deploy_rbac.tf` | RBAC paired with each team connection's deploy identity |
| `service_connection_access.tf` | Per-team SC allowlists and name checks |
| `library_access.tf` | Project-level Library deny, then per-catalog Allow for VGs and environments |
| `pipeline_access.tf` | Pipeline-folder permissions per team |
| `repo_access.tf` | Repository permissions and cross-team denies |
| `acr_scope_tokens.tf` | Per-path ACR scope maps |
| `outputs.tf` | Allowlists, mismatch reports, and scope checks |
