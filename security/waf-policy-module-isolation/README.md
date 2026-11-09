# waf-policy-module-isolation

Runnable Terraform example: WAF policies split into per-group modules (one module block per region/team group), so `-target` addresses stay fixed and blast radius stays small.

No Azure credentials or subscription needed: Azure resources are played by `terraform_data` and locals, so `terraform plan` expands the full wiring locally.

## Run

```bash
terraform init
terraform plan
```

## Files

| File | Contents |
|------|----------|
| `sea_dev.auto.tfvars` / `sea_prod.auto.tfvars` | SEA group's policies per environment |
| `relay_dev.auto.tfvars` / `relay_prod.auto.tfvars` | relay's policies, kept in its own group |
| `variables.tf` | Input shapes for the four policy sets |
| `locals.tf` | Grouped policy assembly |
| `main.tf` | One `module` block per group (fixed `-target` addresses) |
| `modules/policy_group/` | The reusable policy-group module |

The `_anti_pattern/` folder holds the don't-do-this variant (all policies through one root-level `for_each`).

## Try

`terraform plan -target='module.sea[0]'` touches only the SEA group's dev + prod policies.
