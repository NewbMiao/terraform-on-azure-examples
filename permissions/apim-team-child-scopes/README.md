# apim-team-child-scopes

Runnable Terraform example: a hub APIM where platform and Portal split ownership of APIs, policies, and backends, with per-team role assignments at child scopes.

No Azure credentials or subscription needed: Azure resources are played by `terraform_data` and locals, so `terraform plan` expands the full wiring locally.

## Run

```bash
terraform init
terraform plan
```

## Files

| File | Contents |
|------|----------|
| `case.auto.tfvars` | Team APIs; `relay-partner-api` is flagged `portal_managed = true` |
| `variables.tf` | Input shapes for APIs, products, and per-team access |
| `locals.tf` | Platform/portal split and the cartesian products |
| `apim_drift.tf` | `terraform_data` plays the API, policy, backend, product-API link, and assignment, with lifecycle ignores |
| `outputs.tf` | Managed vs. portal-owned scopes and the drift surface |
