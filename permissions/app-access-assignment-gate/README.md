# app-access-assignment-gate

Runnable Terraform example: one SSO group per app with nest-source expansion, a UPN → object ID cache, and an approval-gated Logic App for member adds.

No Azure credentials or subscription needed: Azure resources are played by `terraform_data` and locals, so `terraform plan` expands the full wiring locally.

## Run

```bash
terraform init
terraform plan
```

## Files

| File | Contents |
|------|----------|
| `case.auto.tfvars` | Two nest source groups, two apps, the UPN → object ID cache, and Logic App `caller_apps` |
| `variables.tf` | Input shapes for sources, apps, the cache, and the Logic App |
| `locals.tf` | Source expansion, deduplication, and the `uncached_upns` set |
| `nest_sources.tf` | Source groups and their members |
| `id_cache.tf` | UPN → object ID cache; only cache misses trigger a lookup |
| `assignment_and_membership.tf` | Assignment-required flag, group assignment, SSO group membership |
| `logic_app.tf` | Trigger OAuth policies and the caller catalog |
| `outputs.tf` | Expanded members, cache hits/misses, and the final wiring |
